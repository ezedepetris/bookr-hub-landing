module StripeService
  def self.get_stripe_prices(currency = 'USD')
    begin
      prices = {}

      Config::STRIPE_PRODUCT_IDS.each do |plan, product_id|
        begin
          puts "Getting price for #{plan} with product ID #{product_id}"
          price = product_price_for_currency(product_id, currency) || default_price_for_product(product_id)
          # Convert from cents to dollars/euros/etc
          amount = price.unit_amount / 100.0
          prices[plan] = {
            amount: amount,
            currency: price.currency.upcase,
            formatted: PriceFormatter.format_price(amount, price.currency)
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

  private

  def self.product_price_for_currency(product_id, currency)
    stripe_prices = Stripe::Price.list(product: product_id, currency: currency.downcase, active: true)
    stripe_prices&.data&.first
  rescue StandardError => e
    puts "Error getting product price for currency #{currency}: #{e.message}"
    nil
  end

  def self.default_price_for_product(product_id)
    puts "\n\n\n\n\n"
    puts "Stripe::Product.retrieve(product_id)"
    puts "\n\n\n\n\n"
    default_price = Stripe::Product.retrieve(product_id)&.default_price
    Stripe::Price.retrieve(default_price)
  end

  def self.get_default_price(plan, currency)
    amount = Config.default_price(plan, currency)
    {
      amount: amount,
      currency: currency,
      formatted: PriceFormatter.format_price(amount, currency)
    }
  end
end
