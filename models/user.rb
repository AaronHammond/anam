# encoding: utf-8
class User < Sequel::Model
	one_to_many :backups
end