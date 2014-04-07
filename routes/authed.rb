# encoding: utf-8
class MyApp < Sinatra::Application

	CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
	CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

	get "/authed" do
		erb :authed, :locals => {:client_id => CLIENT_ID}
	end
end
