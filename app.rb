require 'sinatra'
require 'net/http'
require 'json'
require 'date'
require 'stripe'
require 'dotenv/load'
require 'i18n'
require 'i18n/backend/fallbacks'

# Load custom modules
require_relative 'lib/config'
require_relative 'lib/location_helper'
require_relative 'lib/price_formatter'
require_relative 'lib/stripe_service'
require_relative 'lib/sitemap_generator'

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

# Locale to Currency mapping
LOCALE_CURRENCY_MAP = {
  'en-US' => 'USD',
  'en-GB' => 'GBP',
  'en-NZ' => 'NZD',
  'es-AR' => 'ARS',
  'es' => 'USD',  # Default for Spanish (can be overridden)
  'en' => 'USD'   # Default for English
}.freeze

before do
  # Priority 1: Check URL parameters for locale and currency
  if params[:locale]
    locale_param = params[:locale].to_sym
    if I18n.available_locales.include?(locale_param)
      session[:locale] = locale_param
      # Auto-set currency based on locale if currency not explicitly provided
      unless params[:currency]
        locale_str = locale_param.to_s
        session[:currency] = LOCALE_CURRENCY_MAP[locale_str] || LOCALE_CURRENCY_MAP[locale_str.split('-').first] || 'USD'
      end
    else
      # Try base locale if specific locale not available
      base_locale = locale_param.to_s.split('-').first.to_sym
      session[:locale] = I18n.available_locales.include?(base_locale) ? base_locale : I18n.default_locale
      # Auto-set currency based on locale if currency not explicitly provided
      unless params[:currency]
        locale_str = session[:locale].to_s
        session[:currency] = LOCALE_CURRENCY_MAP[locale_str] || LOCALE_CURRENCY_MAP[locale_str.split('-').first] || 'USD'
      end
    end
  end

  if params[:currency]
    session[:currency] = params[:currency].upcase
  end

  # Priority 2: Use session values if URL params not provided
  # Priority 3: Fall back to IP detection only if no session values exist
  location = { "locale" => "en" }

  unless session[:currency]
    ip = request.env['HTTP_X_FORWARDED_FOR']&.split(',')&.first&.strip ||
         request.env['HTTP_X_REAL_IP'] ||
         request.ip

    ip = "8.8.8.8" if ip == "127.0.0.1" # fallback for local dev

    location = LocationHelper.get_location_data(ip)
    session[:currency] = location["currency"] || "USD"
  end

  unless session[:locale]
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
  end

  # Set i18n locale based on session
  I18n.locale = session[:locale]
end

get '/' do
  @prices = StripeService.get_stripe_prices(session[:currency])
  @locale_currency_map = LOCALE_CURRENCY_MAP
  erb :index
end

get '/privacy' do
  erb :privacy
end

get '/oops' do
  erb :oops
end

# ==================== SEO PAGES ====================

# Helper to setup common variables
def setup_seo_page(locale = nil)
  locale ||= session[:locale] || :en
  I18n.locale = locale
  @locale_currency_map = LOCALE_CURRENCY_MAP
  @prices = StripeService.get_stripe_prices(session[:currency] || 'USD')
end

# Spanish pages
get '/turnos' do
  setup_seo_page(:es)
  erb :index
end

get '/reservas-online' do
  setup_seo_page(:es)
  erb :index
end

get '/agendar' do
  setup_seo_page(:es)
  erb :index
end

get '/reserva-de-citas' do
  setup_seo_page(:es)
  erb :index
end

get '/turnos-online' do
  setup_seo_page(:es)
  erb :index
end

# Competitor alternative pages
get '/vs-fresha' do
  setup_seo_page(:en)
  erb :index
end

get '/vs-calendly' do
  setup_seo_page(:en)
  erb :index
end

get '/vs-setmore' do
  setup_seo_page(:en)
  erb :index
end

get '/vs-timely' do
  setup_seo_page(:en)
  erb :index
end

get '/vs-kitomba' do
  setup_seo_page(:en)
  erb :index
end

# Spanish alternatives
get '/alternativa-a-fresha' do
  setup_seo_page(:es)
  erb :index
end

get '/alternativa-a-agendapro' do
  setup_seo_page(:es)
  erb :index
end

# Niche pages
get '/booking-system-for-:niche' do
  setup_seo_page(:en)
  erb :index
end

# Location pages
get '/booking-system-for-:niche-in-:city' do
  setup_seo_page(:en)
  erb :index
end

# Template pages
get '/templates/:template' do
  setup_seo_page(:en)
  erb :index
end

# Free booking page
get '/free-booking' do
  setup_seo_page(:en)
  erb :index
end

# About page
get '/about' do
  setup_seo_page
  erb :index
end

# Contact page
get '/contact' do
  setup_seo_page
  erb :index
end

# Features page
get '/features' do
  setup_seo_page
  erb :index
end

# Pricing page
get '/pricing' do
  setup_seo_page
  erb :index
end

# ==================== END SEO PAGES ====================

get '/robots.txt' do
  content_type 'text/plain'
  base_url = I18n.t('site.canonical_url', locale: :en)
  "User-agent: *\nAllow: /\n\nSitemap: #{base_url}/sitemap.xml"
end

get '/sitemap.xml' do
  content_type 'application/xml; charset=utf-8'
  headers 'Cache-Control' => 'public, max-age=3600'
  SitemapGenerator.generate(LOCALE_CURRENCY_MAP)
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
