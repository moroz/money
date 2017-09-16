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

  def +(addend)
    raise TypeError unless addend.instance_of?(Money)
    converted = addend.convert_to(currency)
    sum = amount + converted.amount
    Money.new(sum, currency)
  end

  def -(subtrahend)
    raise TypeError unless subtrahend.instance_of?(Money)
    converted = subtrahend.convert_to(currency)
    difference = amount - converted.amount
    Money.new(difference, currency)
  end

  def *(factor)
    raise TypeError unless factor.kind_of?(Numeric)
    factor = BigDecimal(factor)
    Money.new(amount * factor, currency)
  end

  def /(divisor)
    raise TypeError unless divisor.kind_of?(Numeric)
    divisor = BigDecimal(divisor)
    Money.new(amount / divisor, currency)
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
