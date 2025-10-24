require 'sinatra'
require 'net/http'
require 'json'
require 'stripe'
require 'dotenv/load'
require 'i18n'
require 'i18n/backend/fallbacks'

# Load custom modules
require_relative 'lib/config'
require_relative 'lib/location_helper'
require_relative 'lib/price_formatter'
require_relative 'lib/stripe_service'

enable :sessions

# Configure Stripe
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

# Configure i18n
I18n.enforce_available_locales = false
I18n.load_path = Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml')]
I18n.default_locale = :en

# Enable fallbacks
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)

set :public_folder, File.dirname(__FILE__) + '/public'

before do
  location = { "locale" => "en" }

  unless session[:currency]
    ip = request.env['HTTP_X_FORWARDED_FOR']&.split(',')&.first&.strip ||
         request.env['HTTP_X_REAL_IP'] ||
         request.ip

    ip = "8.8.8.8" if ip == "127.0.0.1" # fallback for local dev

    location = LocationHelper.get_location_data(ip)
    session[:currency] = location["currency"] || "USD"
  end

  sanitized_location_locale = location["languages"].to_s.split(',').first.to_s.strip
  location_locale = (sanitized_location_locale.length > 0 ? sanitized_location_locale.to_sym : 'en')

  # Check if the generated locale (e.g., :'es-MX') is valid
  if I18n.available_locales.include?(location_locale)
    session[:locale] = location_locale
  else
    # If the specific locale isn't available, fall back to the base language
    # For example, if es-MX is invalid, use :es if available, otherwise use default
    base_locale = location_locale.to_s.split('-').first.to_sym
    if I18n.available_locales.include?(base_locale)
      session[:locale] = base_locale
    else
      session[:locale] = I18n.default_locale
    end
  end

  # Set i18n locale based on session
  I18n.locale = session[:locale]
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
