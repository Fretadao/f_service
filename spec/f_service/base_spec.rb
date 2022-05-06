# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService::Base do
  describe '#success' do
    subject(:response) { described_class.new.success('yay!') }

    it { expect(response.value).to eq('yay!') }
  end

  describe '#Success' do
    subject(:response) { described_class.new.Success(:ok, data: 'yay!') }

    it { expect(response.type).to eq(:ok) }
    it { expect(response.value).to eq('yay!') }
  end

  describe '#failure' do
    subject(:response) { described_class.new.failure('Whoops!') }

    it { expect(response.error).to eq('Whoops!') }
  end

  describe '#Failure' do
    subject(:response) { described_class.new.Failure(:error, data: 'Whoops!') }

    it { expect(response.type).to eq(:error) }
    it { expect(response.error).to eq('Whoops!') }
  end

  describe '#Check' do
    context 'when block evaluates to true' do
      subject(:response) { described_class.new.Check(:math_works) { 1 < 2 } }

      it { expect(response).to be_successful }
      it { expect(response.type).to eq(:math_works) }
      it { expect(response.value!).to eq(true) }
    end

    context 'when block evaluates to false' do
      subject(:response) { described_class.new.Check(:math_works) { 1 > 2 } }

      it { expect(response).to be_failed }
      it { expect(response.type).to eq(:math_works) }
      it { expect(response.error).to eq(false) }
    end

    context 'when type is not specified' do
      subject(:response) { described_class.new.Check { 1 > 2 } }

      it { expect(response).to be_failed }
      it { expect(response.type).to eq(nil) }
      it { expect(response.error).to eq(false) }
    end

    context 'when data is passed' do
      subject(:response) { described_class.new.Check(data: 'that is an error') { 1 > 2 } }

      it { expect(response).to be_failed }
      it { expect(response.type).to eq(nil) }
      it { expect(response.error).to eq('that is an error') }
    end
  end

  describe '#Try' do
    subject(:response) { described_class.new.Try(:division) { 0 / 1 } }

    it { expect(response).to be_successful }
    it { expect(response.type).to eq(:division) }
    it { expect(response.value!).to eq(0) }

    context 'when some exception is raised' do
      subject(:response) { described_class.new.Try(:division) { 1 / 0 } }

      it { expect(response).to be_failed }
      it { expect(response.type).to eq(:division) }
      it { expect(response.error).to be_a ZeroDivisionError }
    end

    context 'when type is not specified' do
      subject(:response) { described_class.new.Try { 0 / 1 } }

      it { expect(response).to be_successful }
      it { expect(response.type).to eq(nil) }
      it { expect(response.value!).to eq 0 }
    end

    context 'when raised exception does not match specified exception' do
      subject(:response) { described_class.new.Try(catch: ZeroDivisionError) { 1 / '0' } }

      it { expect { response }.to raise_error TypeError }
    end
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

  describe '.to_proc' do
    let(:double_number) do
      Class.new(described_class) do
        def initialize(number:)
          @number = number
        end

        def run
          Success(data: @number * 2)
        end
      end
    end

    it 'converts the class name to a proc' do
      values = [{ number: 1 }, { number: 2 }, { number: 3 }].map(&double_number).map(&:value!)

      expect(values).to eq([2, 4, 6])
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
