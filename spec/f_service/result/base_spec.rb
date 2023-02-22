# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService::Result::Base do
  describe 'not implmented methods' do
    let(:test_class) { Class.new(described_class) }

    %i[and_then successful? failed? value value! error].each do |method_name|
      context 'when subclasses do not override methods' do
        subject(:method_call) { test_class.new.public_send(method_name) }

        it "raises error on '#{method_name}' call" do
          expect { method_call }.to raise_error NotImplementedError, "called #{method_name} on class Result::Base"
        end
      end
    end
  end

  describe '#type' do
    before { allow(FService).to receive(:deprecate!) }

    context 'when types has just one type' do
      let(:test_class) do
        Class.new(described_class) do
          def initialize
            @types = %i[success]
          end
        end
      end

      it 'deprecates this method', :aggregate_failures do
        expect(test_class.new.type).to eq(:success)
        expect(FService).to have_received(:deprecate!)
      end
    end

    context 'when types has multiple values' do
      let(:test_class) do
        Class.new(described_class) do
          def initialize
            @types = %i[ok success http_response]
            @matching_types = %i[ok success]
          end
        end
      end

      it 'deprecates this method', :aggregate_failures do
        expect(test_class.new.type).to eq(:ok)
        expect(FService).to have_received(:deprecate!)
      end
    end
  end
end
