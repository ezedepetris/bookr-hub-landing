require 'sinatra'
require 'net/http'
require 'json'
require 'stripe'
require 'dotenv/load'
# Dotenv.load

enable :sessions


# Configure Stripe
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

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

  def get_stripe_prices(currency = 'USD')
    begin
      # Define your Stripe price IDs for each plan
      product_ids = {
        'team' => ENV['STRIPE_TEAM_PRODUCT_ID'],
        'business' => ENV['STRIPE_BUSINESS_PRODUCT_ID']
      }

      prices = {}

      product_ids.each do |plan, product_id|
        begin
          puts "Getting price for #{plan} with product ID #{product_id}"
          price = product_price_for_currency(product_id, currency) || default_price_for_product(product_id)
          # Convert from cents to dollars/euros/etc
          amount = price.unit_amount / 100.0
          prices[plan] = {
            amount: amount,
            currency: price.currency.upcase,
            formatted: format_price(amount, price.currency)
          }
          puts "Prices SO FAR: #{prices}"
        rescue Stripe::StripeError
          # Fallback to default prices if Stripe fails
          prices[plan] = get_default_price(plan, currency)
        end
      end

      prices
    rescue
      # Complete fallback if Stripe is completely unavailable
      {
        'team' => get_default_price('team', currency),
        'business' => get_default_price('business', currency)
      }
    end
  end

  def product_price_for_currency(product_id, currency)
    stripe_prices = Stripe::Price.list(product: product_id, currency: currency.downcase, active: true)
    stripe_prices&.data&.first
  rescue StandardError => e
    puts "Error getting product price for currency #{currency}: #{e.message}"
    nil
  end

  def default_price_for_product(product_id)
    default_price = Stripe::Product.retrieve(product_id)&.default_price
    Stripe::Price.retrieve(default_price)
  end

  def get_default_price(plan, currency)
    default_prices = {
      'team' => {
        'USD' => 9.99,
        'EUR' => 8.99,
        'ARS' => 8999,
        'NZD' => 14.99
      },
      'business' => {
        'USD' => 15.99,
        'EUR' => 14.99,
        'ARS' => 14000,
        'NZD' => 17.99
      }

    }

    amount = default_prices[plan][currency] || default_prices[plan]['USD']
    {
      amount: amount,
      currency: currency,
      formatted: format_price(amount, currency)
    }
  end

  def format_price(amount, currency)
    case currency.upcase
    when 'USD', 'GBP'
      "$#{sprintf('%.2f', amount)}"
    when 'NZD'
      "NZ$#{sprintf('%.2f', amount)}"
    when 'EUR'
      "€#{sprintf('%.2f', amount)}"
    when 'ARS'
      "AR$#{sprintf('%.0f', amount)}"
    else
      "$#{sprintf('%.2f', amount)}"
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
  @prices = get_stripe_prices(session[:currency])
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
