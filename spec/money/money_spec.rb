require 'spec_helper'

RSpec.describe Money::Money do

  describe "initialization" do
    context "when given valid params" do
      it "initializes a Money object"
    end

    context "when given empty string as amount" do
      it "raises ArgumentError" do

      end
    end

    context "when given nil as amount" do
      it "raises ArgumentError" do

      end
    end

    context "when given nil as currency" do
      it "raises ArgumentError" do

      end
    end

    context "when given string as currency" do
      it "raises ArgumentError" do

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
