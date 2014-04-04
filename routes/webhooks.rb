

# encoding: utf-8
class MyApp < Sinatra::Application

	# POST /webhooks/new
	#
	# consumes a post with a repo target (i.e. aaronhammond/anam) and creates a new
	#  webhook internally and on github and activates backups 
	post "/webhooks/new" do
		repo_target = params["repo_target"]
		access_token = session["access_token"]

		me = User[:access_token=>access_token]
		if prevBackup = Backup[:repo_target=>repo_target,:user_id=>me.id]
			return "derpy derp"
		end

		client = Octokit::Client.new(:access_token=>access_token)

		backup = Backup.create(:repo_target=>repo_target,:user_id=>me.id)

		begin
			hook = client.create_hook(
				repo_target, 
				'web',
				{
					:url => 'http://anam.io/webhooks/'+backup.id.to_s,
					:content_type => 'json'
				},
				{
					:events => ['push'],
					:active => true
				})
		rescue Exception => e
			puts e
			backup.delete
			return "herppy"
		end
		puts BackupService.runBackup(backup.id)
	end

	# POST /webhooks/:id
	#
	# this is the entry point for a github webhook. :id represents the id of the
	#  backup in the db.
	post "/webhooks/:id" do
		backup_id = params[:id]
		puts BackupService.runBackup(backup_id)
	end

end