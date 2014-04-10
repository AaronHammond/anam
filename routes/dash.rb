# encoding: utf-8
class MyApp < Sinatra::Application

  CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
  CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

  get "/dash" do
  	if not access_token = session["access_token"] or not me = User[:access_token=>access_token]
  		redirect to('/')
    end

    client = Octokit::Client.new(:access_token=>access_token)
    github_user = client.user()
    repos = github_user.rels[:repos].get.data
    backups = []
    # only show repos that aren't already backed up.

    fresh_repos = []
    repos.each do |repo|
      extantBackup = Backup[:user_id=>me.id, :repo_target=>me.username + '/' + repo.name]
      if extantBackup then
        backups.push(extantBackup)
      else
        fresh_repos.push(repo)
      end
    end

    erb :dash, :locals => {:client_id => CLIENT_ID, :repos => fresh_repos, 
    						:backups=> backups, :login => github_user.login}
  end
end
