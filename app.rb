require 'sinatra'
require 'net/http'
require 'json'
require 'stripe'
require 'dotenv/load'

# Load custom modules
require_relative 'lib/config'
require_relative 'lib/location_helper'
require_relative 'lib/price_formatter'
require_relative 'lib/stripe_service'

enable :sessions


# Configure Stripe
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

set :public_folder, File.dirname(__FILE__) + '/public'

# No helpers needed - all functionality moved to modules

before do
  unless session[:locale] && session[:currency]
    ip = request.ip == "127.0.0.1" ? "8.8.8.8" : request.ip # fallback for local dev
    location = LocationHelper.get_location_data(ip)

    country = location["country_code"] || "US"
    session[:locale] = Config.locale_from_country(country)
    session[:currency] = Config.currency_from_country(country)
  end
end

get '/' do
  @prices = StripeService.get_stripe_prices(session[:currency])
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
