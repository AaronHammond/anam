# encoding: utf-8
class MyApp < Sinatra::Application

	CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
	CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

	get "/" do
		@title = "Welcome to MyApp"				
		erb :index, :locals => {:client_id => CLIENT_ID}
	end
end