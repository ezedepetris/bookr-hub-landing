require "sinatra"
require "net/http"
require "json"
require "date"
require "stripe"
require "dotenv/load"
require "i18n"
require "i18n/backend/fallbacks"

# Load custom modules
require_relative "lib/config"
require_relative "lib/location_helper"
require_relative "lib/price_formatter"
require_relative "lib/stripe_service"
require_relative "lib/sitemap_generator"

enable :sessions

# Configure Stripe
Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

# Configure i18n
I18n.enforce_available_locales = false
I18n.load_path = Dir[File.join(File.dirname(__FILE__), "locales", "*.yml")]
I18n.default_locale = :en

# Enable fallbacks
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)

set :public_folder, File.dirname(__FILE__) + "/public"

# Locale to Currency mapping
LOCALE_CURRENCY_MAP = {
  "en-US" => "USD",
  "en-GB" => "GBP",
  "en-NZ" => "NZD",
  "es-AR" => "ARS",
  "es" => "USD",  # Default for Spanish (can be overridden)
  "en" => "USD"   # Default for English
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
        session[:currency] = LOCALE_CURRENCY_MAP[locale_str] || LOCALE_CURRENCY_MAP[locale_str.split("-").first] || "USD"
      end
    else
      # Try base locale if specific locale not available
      base_locale = locale_param.to_s.split("-").first.to_sym
      session[:locale] = I18n.available_locales.include?(base_locale) ? base_locale : I18n.default_locale
      # Auto-set currency based on locale if currency not explicitly provided
      unless params[:currency]
        locale_str = session[:locale].to_s
        session[:currency] = LOCALE_CURRENCY_MAP[locale_str] || LOCALE_CURRENCY_MAP[locale_str.split("-").first] || "USD"
      end
    end
  end

  if params[:currency]
    session[:currency] = params[:currency].upcase
  end

  # Priority 2: Use session values if URL params not provided
  # Priority 3: Fall back to IP detection only if no session values exist
  location = {"locale" => "en"}

  unless session[:currency]
    ip = request.env["HTTP_X_FORWARDED_FOR"]&.split(",")&.first&.strip ||
      request.env["HTTP_X_REAL_IP"] ||
      request.ip

    ip = "8.8.8.8" if ip == "127.0.0.1" # fallback for local dev

    location = LocationHelper.get_location_data(ip)
    session[:currency] = location["currency"] || "USD"
  end

  unless session[:locale]
    sanitized_location_locale = location["languages"].to_s.split(",").first.to_s.strip
    location_locale = ((sanitized_location_locale.length > 0) ? sanitized_location_locale.to_sym : "en")

    # Check if the generated locale (e.g., :'es-MX') is valid
    if I18n.available_locales.include?(location_locale)
      session[:locale] = location_locale
    else
      # If the specific locale isn't available, fall back to the base language
      # For example, if es-MX is invalid, use :es if available, otherwise use default
      base_locale = location_locale.to_s.split("-").first.to_sym
      session[:locale] = if I18n.available_locales.include?(base_locale)
        base_locale
      else
        I18n.default_locale
      end
    end
  end

  # Set i18n locale based on session
  I18n.locale = session[:locale]
end

get "/" do
  @prices = StripeService.get_stripe_prices(session[:currency])
  @locale_currency_map = LOCALE_CURRENCY_MAP
  erb :index
end

get "/privacy" do
  erb :privacy
end

get "/oops" do
  erb :oops
end

get "/robots.txt" do
  content_type "text/plain"
  base_url = I18n.t("site.canonical_url", locale: :en)
  "User-agent: *\nAllow: /\n\nSitemap: #{base_url}/sitemap.xml"
end

get "/sitemap.xml" do
  content_type "application/xml; charset=utf-8"
  headers "Cache-Control" => "public, max-age=3600"
  SitemapGenerator.generate(LOCALE_CURRENCY_MAP)
end

post "/set_locale" do
  session[:locale] = params[:locale]
  session[:currency] = params[:currency]
  redirect back
end

not_found do
  status 404
  erb :oops
end

# ===== STATIC SEO PAGES =====
# Serve pre-generated SEO pages from public/seo/

get "/en/:page" do
  page_path = File.join(settings.public_folder, "seo", "en", "#{params[:page]}.html")
  if File.exist?(page_path)
    send_file page_path
  else
    pass
  end
end

get "/es/:page" do
  page_path = File.join(settings.public_folder, "seo", "es", "#{params[:page]}.html")
  if File.exist?(page_path)
    send_file page_path
  else
    pass
  end
end

get "/:howto_page" do
  # English how-to pages
  en_howto_slugs = %w[
    how-to-accept-bookings-online how-to-reduce-no-shows how-to-start-a-barbershop
    how-to-manage-appointments how-to-send-reminders how-to-take-payments
    how-to-build-a-website how-to-grow-my-business how-to-handle-cancellations
    best-booking-software best-free-booking-system best-booking-app fresha-alternative
    calendly-alternative appointment-scheduler-free online-booking-system-free
    booking-widget-for-website salon-software-reviews barber-shop-software spa-booking-software
    nailsalon-management fitness-booking-system cleaning-business-software personal-trainer-app
  ]

  if en_howto_slugs.include?(params[:howto_page])
    page_path = File.join(settings.public_folder, "seo", "en", "#{params[:howto_page]}.html")
    if File.exist?(page_path)
      send_file page_path
    else
      pass
    end
  else
    pass
  end
end

get "/:comparison_page" do
  # English comparison pages
  comparison_slugs = %w[
    vs-fresha vs-calendly vs-setmore vs-timely vs-appointy vs-simplybook
    vs-square vs-vagaro vs-acuity vs-youcanbook
  ]

  if comparison_slugs.include?(params[:comparison_page])
    page_path = File.join(settings.public_folder, "seo", "en", "#{params[:comparison_page]}.html")
    if File.exist?(page_path)
      send_file page_path
    else
      pass
    end
  else
    pass
  end
end

get "/:niche_page" do
  # English niche landing pages
  niche_slugs = %w[
    booking-system-for-barbers booking-system-for-hair-salons booking-system-for-nail-salons
    booking-system-for-massage-spa booking-system-for-personal-trainers booking-system-for-cleaners
    booking-system-for-beauty-salons
  ]

  if niche_slugs.include?(params[:niche_page])
    page_path = File.join(settings.public_folder, "seo", "en", "#{params[:niche_page]}.html")
    if File.exist?(page_path)
      send_file page_path
    else
      pass
    end
  else
    pass
  end
end

get "/sistema-de-turnos-para-:niche" do
  # Spanish niche pages
  niche_slugs = %w[
    barbers hair-salons nail-salons massage-spa personal-trainers cleaners beauty-salons
  ]

  if niche_slugs.include?(params[:niche])
    page_path = File.join(settings.public_folder, "seo", "es", "sistema-de-turnos-para-#{params[:niche]}.html")
    if File.exist?(page_path)
      send_file page_path
    else
      pass
    end
  else
    pass
  end
end

get "/como-:howto_page" do
  # Spanish how-to pages (como- prefix)
  es_howto_slugs = %w[
    aceptar-reservas-online reducir-cancelaciones crear-una-peluqueria
    software-de-turnos-gratis sistema-de-reservas-online
    app-para-agendar-turnos gestionar-turnos recordatorios-de-turnos
    pagos-online-negocio crear-pagina-de-reservas mejor-software-peluquerias
    software-barberia sistema-spa-gratis app-salon-de-belleza software-gimnasio
    agenda-online-negocio reservas-desde-whatsapp automatizar-turnos
    plantilla-reserva-negocios guia-reservas-online tips-negocio-belleza
    marketing-salones herramientas-peluqueros comparativa-software-reservas
  ]

  if es_howto_slugs.include?(params[:howto_page])
    page_path = File.join(settings.public_folder, "seo", "es", "como-#{params[:howto_page]}.html")
    if File.exist?(page_path)
      send_file page_path
    else
      pass
    end
  else
    pass
  end
end

get "/alternativa-a-:competitor" do
  # Spanish alternative pages (alternativa-a- prefix)
  competitors = %w[fresha agendapro calendly setmore]
  if competitors.include?(params[:competitor])
    page_path = File.join(settings.public_folder, "seo", "es", "alternativa-a-#{params[:competitor]}.html")
    if File.exist?(page_path)
      send_file page_path
    else
      pass
    end
  else
    pass
  end
end

# Dynamic routes for niche + city pages (English and Spanish)
get "/booking-system-for-:niche-in-:city" do
  page_path = File.join(settings.public_folder, "seo", "en", "booking-system-for-#{params[:niche]}-in-#{params[:city]}.html")
  if File.exist?(page_path)
    send_file page_path
  else
    pass
  end
end

get "/sistema-de-turnos-para-:niche-en-:city" do
  page_path = File.join(settings.public_folder, "seo", "es", "sistema-de-turnos-para-#{params[:niche]}-en-#{params[:city]}.html")
  if File.exist?(page_path)
    send_file page_path
  else
    pass
  end
end

# General EN pages
get "/why-bookrhub" do
  page_path = File.join(settings.public_folder, "seo", "en", "why-bookrhub.html")
  send_file page_path if File.exist?(page_path)
end

get "/best-booking-system" do
  page_path = File.join(settings.public_folder, "seo", "en", "best-booking-system.html")
  send_file page_path if File.exist?(page_path)
end

get "/best-free-booking-system" do
  page_path = File.join(settings.public_folder, "seo", "en", "best-free-booking-system.html")
  send_file page_path if File.exist?(page_path)
end

get "/free-online-booking-system" do
  page_path = File.join(settings.public_folder, "seo", "en", "free-online-booking-system.html")
  send_file page_path if File.exist?(page_path)
end

get "/online-booking-system" do
  page_path = File.join(settings.public_folder, "seo", "en", "online-booking-system.html")
  send_file page_path if File.exist?(page_path)
end

get "/booking-software-for-small-business" do
  page_path = File.join(settings.public_folder, "seo", "en", "booking-software-for-small-business.html")
  send_file page_path if File.exist?(page_path)
end

get "/appointment-booking-software" do
  page_path = File.join(settings.public_folder, "seo", "en", "appointment-booking-software.html")
  send_file page_path if File.exist?(page_path)
end

get "/salon-booking-software" do
  page_path = File.join(settings.public_folder, "seo", "en", "salon-booking-software.html")
  send_file page_path if File.exist?(page_path)
end

get "/barber-shop-app" do
  page_path = File.join(settings.public_folder, "seo", "en", "barber-shop-app.html")
  send_file page_path if File.exist?(page_path)
end

get "/booking-app-for-business" do
  page_path = File.join(settings.public_folder, "seo", "en", "booking-app-for-business.html")
  send_file page_path if File.exist?(page_path)
end

get "/no-shows-solution" do
  page_path = File.join(settings.public_folder, "seo", "en", "no-shows-solution.html")
  send_file page_path if File.exist?(page_path)
end

get "/booking-website-maker" do
  page_path = File.join(settings.public_folder, "seo", "en", "booking-website-maker.html")
  send_file page_path if File.exist?(page_path)
end

# General ES pages
get "/por-que-bookrhub" do
  page_path = File.join(settings.public_folder, "seo", "es", "por-que-bookrhub.html")
  send_file page_path if File.exist?(page_path)
end

get "/mejor-sistema-de-reservas" do
  page_path = File.join(settings.public_folder, "seo", "es", "mejor-sistema-de-reservas.html")
  send_file page_path if File.exist?(page_path)
end

get "/mejor-sistema-de-turnos-gratis" do
  page_path = File.join(settings.public_folder, "seo", "es", "mejor-sistema-de-turnos-gratis.html")
  send_file page_path if File.exist?(page_path)
end

get "/sistema-de-reservas-online-gratis" do
  page_path = File.join(settings.public_folder, "seo", "es", "sistema-de-reservas-online-gratis.html")
  send_file page_path if File.exist?(page_path)
end

get "/software-de-turnos-para-pequenos-negocios" do
  page_path = File.join(settings.public_folder, "seo", "es", "software-de-turnos-para-pequenos-negocios.html")
  send_file page_path if File.exist?(page_path)
end

get "/app-para-barberia" do
  page_path = File.join(settings.public_folder, "seo", "es", "app-para-barberia.html")
  send_file page_path if File.exist?(page_path)
end

get "/solucion-para-inasistencias" do
  page_path = File.join(settings.public_folder, "seo", "es", "solucion-para-inasistencias.html")
  send_file page_path if File.exist?(page_path)
end

get "/crear-pagina-de-reservas-web" do
  page_path = File.join(settings.public_folder, "seo", "es", "crear-pagina-de-reservas-web.html")
  send_file page_path if File.exist?(page_path)
end

get "/software-para-peluquerias-gratis" do
  page_path = File.join(settings.public_folder, "seo", "es", "software-para-peluquerias-gratis.html")
  send_file page_path if File.exist?(page_path)
end

get "/sistema-reservas-whatsapp" do
  page_path = File.join(settings.public_folder, "seo", "es", "sistema-reservas-whatsapp.html")
  send_file page_path if File.exist?(page_path)
end
