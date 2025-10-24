module PriceFormatter
  def self.format_price(amount, currency)
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
