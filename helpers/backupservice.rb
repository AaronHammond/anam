# encoding: utf-8

require 'aws-sdk'
require 'httparty'
module BackupService

	# runBackup
	#
	# Required: 
	#   [0] id: the backup target to run (external_id!)
	# 
	# Returns:
	 
	def self.runBackup(id)
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

end