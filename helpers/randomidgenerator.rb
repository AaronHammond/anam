require 'securerandom'

module RandomIdGenerator

	# random_backup_id
	#  generates a random hex string that we can use as an externally safe index for backups
	# 
	# Returns: s
	 
	def random_backup_id
		# will generate a random 16 char hex string
		try = SecureRandom.hex(8)
		target = Backup[:external_id=>try]
		# if the id is already being used, try again!
		if target then
			return random_backup_id
		end
		return try
	end
	module_function :random_backup_id

end