require 'spec_helper'

def eur_rates
  {'USD' => 1.1885, 'RUB' => 68.648, 'CNY' => 7.7918, 'PHP' => 60.99}
end

def usd_rates
  {'EUR' => 0.8414, 'RUB' => 57.76, 'CNY' => 6.556, 'PHP' => 51.317}
end

include Money

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
end
