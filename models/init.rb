# encoding: utf-8
require 'sequel'
# DB = Sequel.postgres 'dbname', user:'bduser', password:'dbpass', host:'localhost'
# DB << "SET CLIENT_ENCODING TO 'UTF8';"

DB = Sequel.sqlite


DB.create_table :users do
	primary_key :id
	varchar :username, :index=>true
	varchar :email
	varchar :access_token
end

DB.create_table :backups do 
	primary_key :id
	datetime :last_backup
	varchar :repo_target
	varchar :s3_link
	boolean :active, :default=>true
	foreign_key :user_id, :users
end

require_relative 'backup'
require_relative 'user'
  