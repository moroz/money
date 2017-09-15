require "spec_helper"

RSpec.describe Money::Money do
  it "has a version number" do
    expect(Money::VERSION).not_to be nil
  end

  let(:usd) { Currency.fetch_conversion_rates_for('USD') }
  let(:eur) { Currency.fetch_conversion_rates_for('EUR') }

  before do
    stub_request(:get, 'https://api.fixer.io/latest?base=EUR').to_return({
      status: 200,
      body: json_string(json_file('eur'))
    })
  end

  describe "initialization" do
    let(:twenty_eur) { Money.new(20, eur) }
    context "when given valid params" do
      it "initializes a Money object" do
        expect(twenty_eur).to be_instance_of(Money)
      end
    end

    context "when given empty string as amount" do
      it "raises ArgumentError" do
        expect { Money.new('', eur) }.to raise_exception ArgumentError
      end
    end

    context "when given nil as amount" do
      it "raises ArgumentError" do
        expect { Money.new(nil, eur) }.to raise_exception ArgumentError
      end
    end

    context "when given nil as currency" do
      it "raises ArgumentError" do
        expect { Money.new(20, nil) }.to raise_exception ArgumentError
      end
    end

    context "when given string as currency" do
      it "raises ArgumentError" do
        expect { Money.new(20, 'EUR') }.to raise_exception ArgumentError
      end
    end
  end

  describe "conversions" do
    describe '#convert_to' do
      context "when given Currency object" do
        context "when the other Currency is same as own" do
          it "returns self"
        end

        context "when the other Currency is different" do
          it 'returns calculated value' do

          end
        end
      end

      context "when given other type of object" do
        it "raises ArgumentError" do
        end
      end
    end
  end

  describe "comparisons" do
    describe "==" do
      context "when the other object has same amount and currency" do
        it "returns true" do

        end
      end

      context "when the other object is in other currency" do
        context "when equal after conversion" do
          it "returns true" do

          end
        end

        context "when unequal after conversion" do
          it "returns false" do

          end
        end
      end
    end

    describe "!=" do
      context "when the other object has same amount and currency" do
        it "returns false" do

        end
      end

      context "when the other object is in other currency" do
        context "when equal after conversion" do
          it "returns false" do

          end
        end

        context "when unequal after conversion" do
          it "returns true" do

          end
        end
      end

    end
  end
end

