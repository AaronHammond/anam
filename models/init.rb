# encoding: utf-8
require 'sequel'
DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
DB << "SET CLIENT_ENCODING TO 'UTF8';"

# DB = Sequel.sqlite


DB.create_table :users do
	primary_key :id
	varchar :username, :index=>true
	varchar :email
	varchar :access_token
end

DB.create_table :backups do 
	primary_key :id
	timestamp :last_backup
	varchar :repo_target
	varchar :s3_link
	boolean :active, :default=>true
	varchar :external_id, :index=>true
	varchar :webhook_id
	foreign_key :user_id, :users
end

require_relative 'backup'
require_relative 'user'
