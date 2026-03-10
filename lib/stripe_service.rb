module StripeService
  # Returns prices per plan with both monthly and annual (annual shown as per-month = yearly/12).
  # Structure: { 'team' => { monthly: { formatted }, annual_per_month: { formatted } }, ... }
  def self.get_stripe_prices(currency = 'USD')
    begin
      prices = {}

      Config::STRIPE_PRODUCT_IDS.each do |plan, product_id|
        begin
          monthly_price, annual_price = product_prices_by_interval(product_id, currency)

          monthly = if monthly_price
                      amount = monthly_price.unit_amount / 100.0
                      { amount: amount, formatted: PriceFormatter.format_price(amount, monthly_price.currency) }
                    else
                      default = get_default_price(plan, currency)
                      { amount: default[:amount], formatted: default[:formatted] }
                    end

          annual_per_month = if annual_price && annual_price.recurring&.interval == 'year'
                               yearly_amount = annual_price.unit_amount / 100.0
                               per_month = yearly_amount / 12.0
                               { formatted: PriceFormatter.format_price(per_month, annual_price.currency) }
                             else
                               # No annual price in Stripe: show monthly price with "billed annually" label
                               { formatted: monthly[:formatted] }
                             end

          prices[plan] = {
            monthly: monthly,
            annual_per_month: annual_per_month
          }
        rescue Stripe::StripeError
          default = get_default_price(plan, currency)
          prices[plan] = {
            monthly: { amount: default[:amount], formatted: default[:formatted] },
            annual_per_month: { formatted: default[:formatted] }
          }
        end
      end

      prices
    rescue StandardError
      {
        'team' => fallback_plan_prices('team', currency),
        'business' => fallback_plan_prices('business', currency)
      }
    end
  end

  private

  def self.product_prices_by_interval(product_id, currency)
    list = Stripe::Price.list(
      product: product_id,
      currency: currency.downcase,
      active: true
    )
    return [nil, nil] unless list&.data&.any?

    monthly = list.data.find { |p| p.recurring&.interval == 'month' }
    annual = list.data.find { |p| p.recurring&.interval == 'year' }
    # If only one interval exists, use it for both
    monthly ||= list.data.first
    annual ||= list.data.first
    [monthly, annual]
  end

  def self.default_price_for_product(product_id)
    default_price = Stripe::Product.retrieve(product_id)&.default_price
    Stripe::Price.retrieve(default_price) if default_price
  end

  def self.get_default_price(plan, currency)
    amount = Config.default_price(plan, currency)
    {
      amount: amount,
      currency: currency,
      formatted: PriceFormatter.format_price(amount, currency)
    }
  end

  def self.fallback_plan_prices(plan, currency)
    default = get_default_price(plan, currency)
    {
      monthly: { amount: default[:amount], formatted: default[:formatted] },
      annual_per_month: { formatted: default[:formatted] }
    }
  end
end
