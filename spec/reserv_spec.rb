# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Reserv::Base do
  describe '#success' do
    subject(:response) { described_class.new.success('yay!') }

    it { expect(response).to be_a Reserv::Result::Success }
    it { expect(response).to be_successful }
    it { expect(response.value).to eq('yay!') }
    it { expect(response.error).to eq(nil) }
    it { expect(response.value!).to eq('yay!') }
  end

  describe '#failure' do
    subject(:response) { described_class.new.failure('Whoops!') }

    it { expect(response).to be_a Reserv::Result::Failure }
    it { expect(response).to be_failed }
    it { expect(response.error).to eq('Whoops!') }
    it { expect(response.value).to eq(nil) }
    it { expect { response.value! }.to raise_error Reserv::Result::Error }
  end

  describe '#result' do
  end

  describe '.call' do
    let(:test_service) do
      Class.new(described_class) do
        def run
          success('This service is alright')
        end
      end
    end
    let(:error_test_service) do
      Class.new(described_class) do
        def run
          'This should be a Result'
        end
      end
    end

    it { expect(test_service.call).to be_successful }
    it { expect { error_test_service.call }.to raise_error Reserv::Error, 'Services must return a Result' }
  end
end
