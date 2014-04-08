# encoding: utf-8
class MyApp < Sinatra::Application

  CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
  CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

  get "/authed" do
    access_token = session['access_token']
    client = Octokit::Client.new(:access_token=>access_token)
    github_user = client.user()
    repos = github_user.rels[:repos].get.data
    erb :authed, :locals => {:client_id => CLIENT_ID, :repos => repos, :login => github_user.login}
  end
end
