require 'sinatra'
set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  erb :index
end

get '/opps' do
  erb :opps
end

# 404 Error!
not_found do
  status 404
  erb :oops
end
