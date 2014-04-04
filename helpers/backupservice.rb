# encoding: utf-8

require 'aws-sdk'
require 'httparty'
module BackupService

	# runBackup
	#
	# Required: 
	#   [0] id: the backup target to run
	# 
	# Returns: the link to the newly created s3 resource
	 
	def self.runBackup(id)
		#todo: THIS
		target = Backup[id]

		client = Octokit::Client.new(:access_token=>User[target.user_id].access_token)

		download_link = client.archive_link(target.repo_target, :format=>'zipball')
		
		uri = URI.parse(download_link)

		s3 = AWS::S3.new

		repo_archive = s3.buckets['anamnesis-rulez'].objects[target.id.to_s+'.zip']
		if repo_archive.exists? then
			repo_archive.delete
		end

	    repo_archive.write HTTParty.get(download_link).parsed_response
		return repo_archive.public_url
	end

end