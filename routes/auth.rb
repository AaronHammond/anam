# encoding: utf-8

require 'rest-client'
require 'json'

class MyApp < Sinatra::Application

  CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
  CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

  get '/auth/callback' do
    session_code = request.env['rack.request.query_hash']['code']
    result = RestClient.post('https://github.com/login/oauth/access_token',
                             {:client_id => CLIENT_ID,
                              :client_secret => CLIENT_SECRET,
                              :code => session_code},
                              :accept => :json)

    # grab the access token from the response and save it in the session
    access_token = JSON.parse(result)['access_token']
    session['access_token'] = access_token

    # grab the user information from github
    client = Octokit::Client.new(:access_token=>access_token)
    github_user = client.user()

    # user creation/update
    owner = User[:username => github_user.login]
    if not owner then
      # if this user doesn't already exist, create them!
      owner = User.create(:username =>github_user.login, :email => github_user.email, :access_token=>access_token)
    elsif owner.access_token != access_token then
      # if the user exists and they're giving us a new access token, update it!
      owner.update(:access_token=>access_token)
    end

    redirect to('/authed')
  end

end
