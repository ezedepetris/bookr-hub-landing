module Config
  # Default prices for each plan and currency
  DEFAULT_PRICES = {
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
  }.freeze

  # Country to locale mapping
  LOCALE_MAPPING = {
    "NZ" => "en-NZ",
    "AR" => "es-AR",
    "GB" => "en-GB",
    "US" => "en-US"
  }.freeze

  # Country to currency mapping
  CURRENCY_MAPPING = {
    "NZ" => "NZD",
    "AR" => "ARS",
    "GB" => "GBP",
    "US" => "USD"
  }.freeze

  # Stripe product IDs
  STRIPE_PRODUCT_IDS = {
    'team' => ENV['STRIPE_TEAM_PRODUCT_ID'],
    'business' => ENV['STRIPE_BUSINESS_PRODUCT_ID']
  }.freeze

  def self.locale_from_country(country_code)
    LOCALE_MAPPING[country_code] || "en"
  end

  def self.currency_from_country(country_code)
    CURRENCY_MAPPING[country_code] || "USD"
  end

  def self.default_price(plan, currency)
    DEFAULT_PRICES[plan]&.dig(currency) || DEFAULT_PRICES[plan]&.dig('USD')
  end
end
