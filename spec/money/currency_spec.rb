require 'spec_helper'

RSpec.describe Money::Currency do
  let(:currency) { Currency.new('EUR', eur_rates) } 

  describe "initialization" do
    context "with valid code and exchange rates" do
      it "returns an instance of Currency" do
        expect(currency).to be_instance_of(Currency)
      end

      it "does not raise an exception" do
        expect { Currency.new('EUR', eur_rates) }.not_to raise_exception
      end
    end

    context "with code being a Symbol" do
      it "raises ArgumentError" do
        expect { Currency.new(:usd, usd_rates) }.to raise_exception(ArgumentError)
      end
    end

    context "with code being nil" do
      it "raises ArgumentError" do
        expect { Currency.new(nil, usd_rates) }.to raise_exception(ArgumentError)
      end
    end

    context "upon initialization" do
      describe "rates" do
        let(:rates) { currency.rates }

        it "is a Hash" do
          expect(rates).to be_instance_of(Hash) 
        end

        it "all keys are of type String" do
          expect(rates.all? { |k,v| k.is_a?(String) }).to be true
        end

        it "all values are of type BigDecimal" do
          expect(rates.all? { |k,v| v.is_a?(BigDecimal) }).to be true
        end
      end
    end
  end

  describe "self.fetch_conversion_rates_for" do
    before do
      stub_request(:get, 'https://api.fixer.io/latest?base=USD').to_return({
        status: 200,
        body: json_string(json_file('usd'))
      })
    end

    # valid => String with the length of 3
    context "called with valid currency code" do
      let(:fetched_currency) { Currency.fetch_conversion_rates_for('USD') }

      it "sends GET request to fixer.io API" do
        fetched_currency
        expect(WebMock).to have_requested(:get, /api\.fixer\.io/).once
      end

      it "returns an instance of Currency" do
        expect(fetched_currency).to be_instance_of(Currency)
      end

      it "returned object's currency code is correct" do
        expect(fetched_currency.code).to eq('USD')
      end

      it "is case-insensitive" do
        expect(Currency.fetch_conversion_rates_for('uSd')).to eq(fetched_currency)
      end
    end

    context "called with a Symbol param" do
      it "raises ArgumentError" do
        expect { Currency.fetch_conversion_rates_for(:usd) }.to raise_exception(ArgumentError)
      end

      it "does not send HTTP request" do
        begin
          Currency.fetch_conversion_rates_for(:usd)
        rescue ArgumentError
        end
        expect(WebMock).not_to have_requested(:get, /api\.fixer\.io/)
      end
    end
  end
end
