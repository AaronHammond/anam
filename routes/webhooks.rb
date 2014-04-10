

# encoding: utf-8
class MyApp < Sinatra::Application


	# GET /webhooks/list
	#
	# consumes a get and returns all backups for the currently logged in user
	get "/webhooks/list" do
		content_type :json

		if not access_token = session["access_token"] or not me = User[:access_token=>access_token]
			return status 401
		end

		return Backup[:user_id=>me.id].to_json 
	end
	 
	# POST /webhooks/deactivate/:id
	#
	# consumes the external id of a backup and deactivates backup
	post "/webhooks/deactivate/:id" do
		content_type :json

		if not access_token = session["access_token"] or not me = User[:access_token=>access_token]
			return status 401
		end

		if not backup_id = params[:id] or not backup = Backup[:external_id=>backup_id, :user_id=>me.id]
			return status 400
		end
		
		backup.update(:active=>false)

		return backup.to_json
	end


	# POST /webhooks/reactivate/:id
	#
	# consumes the external id of a backup and reactivates backup
	post "/webhooks/reactivate/:id" do
		content_type :json

		if not access_token = session["access_token"] or not me = User[:access_token=>access_token]
			return status 401
		end

		if not backup_id = params[:id] or not backup = Backup[:external_id=>backup_id, :user_id=>me.id]
			return status 400
		end
		
		backup.update(:active=>true)

		return backup.to_json
	end

	# POST /webhooks/delete/:id
	#
	# consumes the external id of a backup and deletes the backup
	post "/webhooks/reactivate/:id" do
		content_type :json

		if not access_token = session["access_token"] or not me = User[:access_token=>access_token]
			return status 401
		end

		if not backup_id = params[:id] or not backup = Backup[:external_id=>backup_id, :user_id=>me.id]
			return status 400
		end
		BackupService.delete(backup)
		return status 200
	end



	# POST /webhooks/new
	#
	# consumes a post with a repo target (i.e. aaronhammond/anam) and creates a new
	#  webhook internally and on github and activates backups 
	post "/webhooks/new" do
		content_type :json

		if not access_token = session["access_token"] or not me = User[:access_token=>access_token]
			return status 401
		end

		if not repo_target = params[:repo_target]
			return status 400
		end

		if prevBackup = Backup[:repo_target=>repo_target,:user_id=>me.id]
			status 409
			return prevBackup.to_json
		end

		client = Octokit::Client.new(:access_token=>access_token)

		backup = Backup.create(:repo_target=>repo_target,:user_id=>me.id,:external_id=>RandomIdGenerator.random_backup_id)

		# TODO: check if we already have a webhook active. if so, delete it!
		begin
			hook = client.create_hook(
				repo_target, 
				'web',
				{
					:url => 'http://anam.io/webhooks/'+backup.external_id,
					:content_type => 'json'
				},
				{
					:events => ['push'],
					:active => true
				})
			backup.update(:webhook_id=>hook.id)
		rescue Exception => e
			puts e
			backup.delete
			status 418
			return e.to_json
		end
		
		status 201
		return backup.to_json
	end

	# POST /webhooks/:id
	#
	# this is the entry point for a github webhook. :id represents the id of the
	#  backup in the db.
	post "/webhooks/:id" do
		backup_id = params[:id]

		backup = BackupService.runBackup(backup_id)

		content_type :json
		status 201
		return backup.to_json
	end

end