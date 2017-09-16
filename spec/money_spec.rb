require "spec_helper"

RSpec.describe Money do
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
    stub_request(:get, 'https://api.fixer.io/latest?base=USD').to_return({
      status: 200,
      body: json_string(json_file('usd'))
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
    let(:fifty_usd) { Money.new(50, usd) }

    describe "#to_s" do
      it "returns amount w/fractional part & currency code" do
        expect(fifty_usd.to_s).to eq("50.00 USD")
      end
    end

    describe '#convert_to' do
      context "when given Currency object" do
        context "when the other Currency is same as own" do
          it "returns equal object" do
            fifty_usd_in_usd = fifty_usd.convert_to(usd)
            expect(fifty_usd_in_usd).to eq(fifty_usd)
          end
        end

        context "when the other Currency is different" do
          let(:fifty_usd_in_eur) { fifty_usd.convert_to(eur) }

          it 'returns instance of Money' do
            expect(fifty_usd_in_eur).to be_instance_of(Money)
          end

          # Conversion rates in the fixtures:
          # USD-EUR: 0.8414
          it 'calculates the amounts correctly' do
            expect(fifty_usd_in_eur.amount).to eq(BigDecimal.new(42.07, 4))
          end

          it 'returned object has the valid currency code' do
            expect(fifty_usd_in_eur.currency_code).to eq('EUR')
          end
        end
      end

      context "when given other type of object" do
        it "raises ArgumentError" do
          expect { fifty_usd.convert_to('EUR') }.to raise_exception(ArgumentError)
        end
      end
    end
  end

  describe "comparisons" do
    describe "==" do
      context "when the other object has same amount and currency" do
        it "returns true" do
          twenty_eur = Money.new(20, eur)
          another_twenty_eur = Money.new(20, eur)
          expect(another_twenty_eur).to eq(twenty_eur)
        end
      end

      context "when the other object is in other currency" do
        context "when equal after conversion" do
          it "returns true" do
            fifty_usd = Money.new(50, usd)
            forty_two_eur = Money.new(42.07, eur)
            expect(forty_two_eur).to eq(fifty_usd)
          end
        end

        context "when unequal after conversion" do
          it "returns false" do
            twenty_usd = Money.new(20, usd)
            thousand_eur = Money.new(1000, eur)
            expect(twenty_usd).not_to eq(thousand_eur)
          end
        end
      end
    end
  end

  describe "arithmetics" do
    let(:twenty_eur) { Money.new(20, eur) }

    describe "addition" do
      context "when called with anything but an instance of Money" do
        it "raises TypeError" do
          expect { twenty_eur + 20 }.to raise_exception(TypeError)
        end
      end

      context "when called with instance of Money" do
        context "of the same currency" do
          it "calculates amount correctly" do
            thirty_eur = Money.new(30, eur)
            sum = twenty_eur + thirty_eur
            expect(sum.amount).to eq(50)
          end
        end

        context "of other currency" do
          let(:thirty_usd) { Money.new(30, usd) }

          before(:each) do
            @sum = twenty_eur + thirty_usd
          end

          it "calculates amount correctly" do
            expect(@sum.amount).to eq(BigDecimal.new(45.24, 4))
          end

          it "result is in left operand's currency" do
            expect(@sum.currency_code).to eq('EUR')
          end
        end
      end
    end

    describe "subtraction" do
      context "when called with anything but an instance of Money" do
        it "raises TypeError" do
          expect { twenty_eur - 20 }.to raise_exception(TypeError)
        end
      end

      context "when called with instance of Money" do
        context "of the same currency" do
          it "calculates amount correctly" do
            five_eur = Money.new(5, eur)
            difference = twenty_eur - five_eur
            expect(difference.amount).to eq(15)
          end
        end

        context "of other currency" do
          let(:ten_usd) { Money.new(10, usd) }

          before(:each) do
            @result = twenty_eur - ten_usd
          end

          # USD-EUR: 0.8414
          it "calculates amount correctly" do
            expect(@result.amount).to eq(11.59)
          end

          it "result is in left operand's currency" do
            expect(@result.currency_code).to eq('EUR')
          end
        end
      end
    end

    describe "multiplication" do
      describe "with wrong param" do
        context "when called with another instance of Money" do
          it "raises TypeError" do
            other = Money.new(3, usd)
            expect { twenty_eur * other }.to raise_exception(TypeError)
          end
        end

        context "when called with nil" do
          it "raises TypeError" do
            expect { twenty_eur * nil }.to raise_exception(TypeError)
          end
        end

        context "when called with a string" do
          it "raises TypeError" do
            expect { twenty_eur * 'foobar' }.to raise_exception(TypeError)
          end
        end
      end

      describe "with a number" do
        before(:each) do
          @result = twenty_eur * 3.5
        end

        it "calculates amount correctly" do
          expect(@result.amount).to eq(70)
        end

        it "returns instance of Money" do
          expect(@result).to be_instance_of(Money)
        end

        it "result has the same currency" do
          expect(@result.currency_code).to eq('EUR')
        end
      end
    end

    describe "diEvision" do
      context "with wrong param" do
        context "when called with another instance of Money" do
          it "raises TypeError" do
            other = Money.new(3, usd)
            expect { twenty_eur / other }.to raise_exception(TypeError)
          end
        end

        context "when called with nil" do
          it "raises TypeError" do
            expect { twenty_eur / nil }.to raise_exception(TypeError)
          end
        end

        context "when called with a string" do
          it "raises TypeError" do
            expect { twenty_eur / 'foobar' }.to raise_exception(TypeError)
          end
        end
      end

      describe "division by zero" do
        it "raises ZeroDivisionError" do
          expect { twenty_eur / 0 }.to raise_exception(ZeroDivisionError)
        end
      end

      describe "with a non-zero real number" do
        before(:each) do
          @result = twenty_eur / 2
        end

        it "calculates amount correctly" do
          expect(@result.amount).to eq(10)
        end

        it "returns instance of Money" do
          expect(@result).to be_instance_of(Money)
        end

        it "result has the same currency" do
          expect(@result.currency_code).to eq('EUR')
        end
      end
    end
  end
end
