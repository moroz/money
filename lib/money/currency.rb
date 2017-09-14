require 'bigdecimal'
require 'httparty'

# Money::Currency
# A very simple class to store a currency code and its exchange rates to other
# currencies. It is intended for use with Money::Money.
# The typical way to initialize an instance of Currency would be using
# Currency.fetch_conversion_rates_for(code), the code being a string with a
# valid ISO 4217 currency code, e.g. USD, EUR, CNY (not: RMB), PLN, TWD (not: NTD).

module Money
  class Currency
    attr_reader :rates, :code

    include HTTParty
    base_uri "https://api.fixer.io"

    # Can be initialized the normal way but you have to provide a full list of exchange @rates
    # @code is the standard ISO 4217 code
    def initialize(code, rates)
      raise ArgumentError.new("code is not a valid ISO 4217 currency code") unless code.is_a?(String) && code.length == 3
      @code = code.upcase

      @rates = convert_rates_to_big_decimal(rates)
    end

    def self.fetch_conversion_rates_for(code)
      raise ArgumentError.new("code is not a valid ISO 4217 currency code") unless code.is_a?(String) && code.length == 3
      api_response = self.get('/latest', query: { base: code.upcase })

      # When stubbing responses with WebMock, HTTParty returns unparsed JSON string
      if api_response.success?
        body = api_response.parsed_response
        body = JSON.parse(body) if body.is_a?(String)
        Currency.new(body['base'], body['rates'])
      else
        error_message = JSON.parse(api_response.parsed_response['error'])
        raise RuntimeError.new("Fetching currency data failed with response code #{api_response.response.code}: #{error_message}")
      end
    end

    def ==(other)
      self.code == other.code && self.rates == other.rates
    end

    private

    # convert all exchange rates to BigDecimal to maintain precision
    def convert_rates_to_big_decimal(hash)
      Hash[hash.map { |c, r| [c, BigDecimal.new(r, 5)] }]
    end
  end
end
