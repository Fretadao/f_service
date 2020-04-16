# frozen_string_literal: true

require 'spec_helper'

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
    subject(:response) { described_class.new.result(condition) }

    context 'when condition is true' do
      let(:condition) { 1 < 2 }

      it { expect(response).to be_successful }
    end

    context 'when condition is false' do
      let(:condition) { 1 > 2 }

      it { expect(response).to be_failed }
    end
  end

  describe '.call' do
    let(:test_service) do
      Class.new(described_class) do
        def run
          success('This service is alright')
        end
      end
    end
    let(:service_with_invalid_return) do
      Class.new(described_class) do
        def run
          'This should be a Result'
        end
      end
    end
    let(:service_without_run) { Class.new(described_class) }

    it { expect(test_service.call).to be_successful }
    it { expect { service_with_invalid_return.call }.to raise_error FService::Error, 'Services must return a Result' }
    it { expect { service_without_run.call }.to raise_error NotImplementedError, 'Services must implement #run' }
  end
end
