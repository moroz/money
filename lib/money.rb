require "money/version"
require 'currency'
require 'bigdecimal'

class Money
  attr_reader :amount, :currency

  include Comparable

  # Takes amount and a Currency object
  def initialize(amount, currency)
    raise ArgumentError if amount.nil? || amount == '' || !currency.is_a?(Currency)

    # log10 rounded to ceiling == number of digits before the point
    # we add 2 to get the number of significant digits with cents
    precision = Math.log10(amount.to_f).ceil + 2
    @amount = BigDecimal.new(amount, precision)
    @currency = currency
  end

  def to_s
    sprintf("%.2f %s", amount, currency_code)
  end

  def currency_code
    currency.code
  end

  def +(other)

  end

  def convert_to(new_currency)
    raise ArgumentError unless new_currency.instance_of?(Currency)
    return self if new_currency == self.currency
    rate = self.currency.rates[new_currency.code]
    Money.new((amount * rate).round(2), new_currency)
  end

  def <=>(other)
    return unless other.instance_of?(Money)
    converted = other.convert_to(self.currency)
    self.amount <=> converted.amount
  end
end
