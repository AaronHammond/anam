# encoding: utf-8

require 'aws-sdk'
require 'httparty'
module BackupService

	# runBackup
	#
	# Required: 
	#   [0] id: the backup target to run (external_id!)
	# 
	# Returns: the backup object, with new populated information about the backup
	 
	def runBackup(id)
		target = Backup[:external_id =>id]

		if not target.active
			return target
		end
		client = Octokit::Client.new(:access_token=>User[target.user_id].access_token)

		download_link = client.archive_link(target.repo_target, :format=>'zipball')
		
		uri = URI.parse(download_link)

		s3 = AWS::S3.new

		repo_archive = s3.buckets['anamnesis-112358'].objects[target.external_id+'.zip']
		if repo_archive.exists? then
			repo_archive.delete
		end

	    repo_archive.write HTTParty.get(download_link).parsed_response, :acl=>:public_read
	    target.update(:s3_link=>repo_archive.public_url, :last_backup=>Time.now)
		return target
	end
	module_function :runBackup

	# deleteBackup(id)
	#
	# consumes an external id, and deletes the s3 copy, the db object, and the github hook
	#
	# Required: 
	#   [0] target: the backup target to delete
	# 
	# Returns: void
	 
	def deleteBackup(target)
		
		client = Octokit::Client.new(:access_token=>User[target.user_id].access_token)

		# delete github hook
		client.remove_hook(target.repo_target, target.webhook_id)
		# delete on s3
		s3 = AWS::S3.new
		repo_archive = s3.buckets['anamnesis-112358'].objects[target.external_id+'.zip']
		if repo_archive.exists? then
			repo_archive.delete
		end

		# finally, delete it :(s)
		target.delete
	end
	module_function :deleteBackup

end