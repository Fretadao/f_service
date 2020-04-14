# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe FService::Base do
  describe '#success' do
    subject(:response) { described_class.new.success('yay!') }

    it { expect(response.value).to eq('yay!') }
  end

  describe '#failure' do
    subject(:response) { described_class.new.failure('Whoops!') }

    it { expect(response.error).to eq('Whoops!') }
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
    it { expect { error_test_service.call }.to raise_error FService::Error, 'Services must return a Result' }
  end
end
