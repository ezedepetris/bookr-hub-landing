require 'sinatra'
require 'net/http'
require 'json'
enable :sessions

set :public_folder, File.dirname(__FILE__) + '/public'

helpers do
  def get_location_data(ip)
    uri = URI("https://ipapi.co/#{ip}/json/")
    response = Net::HTTP.get(uri)
    JSON.parse(response) rescue {}
  end

  def locale_from_country(country_code)
    case country_code
    when "NZ" then "en-NZ"
    when "AR" then "es-AR"
    when "GB" then "en-GB"
    when "US" then "en-US"
    else "en"
    end
  end

  def currency_from_country(country_code)
    case country_code
    when "NZ" then "NZD"
    when "AR" then "ARS"
    when "GB" then "GBP"
    when "US" then "USD"
    else "USD"
    end
  end
end

before do
  unless session[:locale] && session[:currency]
    ip = request.ip == "127.0.0.1" ? "8.8.8.8" : request.ip # fallback for local dev
    location = get_location_data(ip)

    country = location["country_code"] || "US"
    session[:locale] = locale_from_country(country)
    session[:currency] = currency_from_country(country)
  end
end

get '/' do
  erb :index
end

get '/oops' do
  erb :oops
end

post '/set_locale' do
  session[:locale] = params[:locale]
  session[:currency] = params[:currency]
  redirect back
end

not_found do
  status 404
  erb :oops
end
