require 'sinatra'
require 'net/http'
require 'json'
require 'stripe'
require 'dotenv/load'
require 'i18n'

# Load custom modules
require_relative 'lib/config'
require_relative 'lib/location_helper'
require_relative 'lib/price_formatter'
require_relative 'lib/stripe_service'

enable :sessions


# Configure Stripe
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

# Configure i18n
I18n.load_path = Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml')]
I18n.default_locale = :en
I18n.available_locales = [:en, :'en-US', :'en-GB', :'en-NZ', :'es-AR', :'es']

set :public_folder, File.dirname(__FILE__) + '/public'

# No helpers needed - all functionality moved to modules

before do
  unless session[:locale] && session[:currency]
    # ip = request.ip == "127.0.0.1" ? "8.8.8.8" : request.ip # fallback for local dev
    # require 'net/http'
    ip = request.env['HTTP_X_FORWARDED_FOR']&.split(',')&.first&.strip ||
         request.env['HTTP_X_REAL_IP'] ||
         request.ip
    ip = "8.8.8.8" if ip == "127.0.0.1" # fallback for local dev


    location = LocationHelper.get_location_data(ip)
    puts "IP: #{ip}"
    puts "Location: #{location}"

    country = location["country_code"] || "US"
    session[:locale] = Config.locale_from_country(country)
    session[:currency] = Config.currency_from_country(country)
  end

  # Set i18n locale based on session
  locale_symbol = session[:locale].to_sym
  if I18n.available_locales.include?(locale_symbol)
    I18n.locale = locale_symbol
  else
    I18n.locale = :en # fallback to English
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
