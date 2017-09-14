module CurrencyHelper
  def json_string(filename)
    File.read(filename)
  end

  def json_file(currency)
    File.join(File.dirname(__FILE__), '/fixtures/' + currency.to_s.downcase + '_response.json')
  end

  def rates_for(currency)
    JSON.parse(json_string(json_file(currency)))['rates']
  end

  def eur_rates
    rates_for('eur')
  end

  def usd_rates
    rates_for('usd')
  end
end
