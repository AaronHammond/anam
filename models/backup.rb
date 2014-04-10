# encoding: utf-8
class Backup < Sequel::Model
	many_to_one :user

	def to_json
		{:external_id=>self.external_id, 
			:active=>self.active, 
			:s3_link=>self.s3_link, 
			:last_backup=>self.last_backup,
			:repo_target=>self.repo_target,
			:owner=>self.user.username}.to_json
	end
end