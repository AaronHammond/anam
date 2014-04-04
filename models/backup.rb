# encoding: utf-8
class Backup < Sequel::Model
	many_to_one :user
end