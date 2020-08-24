# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService::Result::Failure do
  subject(:failure) { described_class.new('Whoops!') }

  it { expect(failure).to be_a described_class }
  it { expect(failure).to be_failed }
  it { expect(failure).not_to be_successful }
  it { expect(failure.error).to eq('Whoops!') }
  it { expect(failure.type).to eq(nil) }
  it { expect(failure.value).to eq(nil) }
  it { expect { failure.value! }.to raise_error FService::Result::Error }

  context 'when defining a type' do
    subject(:failure) { described_class.new('Whoops!', :error) }

    it { expect(failure.type).to eq(:error) }
  end

  describe '#on' do
    context 'when matching results' do
      subject(:failure_match) do
        described_class.new('Whoops!').on(
          success: ->(_value) { raise "This won't ever run" },
          failure: ->(error) { return error + '!' }
        )
      end

      it 'runs on the failure path' do
        expect(failure_match).to eq('Whoops!!')
      end
    end

    context 'when chaining results' do
      subject(:chain) do
        FService::Result::Success.new('This...')
                                 .then { |value| described_class.new(value + ' Fails!') }
                                 .then { |_value| raise "This won't ever run!" }
      end

      it { expect(chain).to be_failed }

      it 'shorts circuit on failures' do
        expect(chain.error).to eq('This... Fails!')
      end
    end
  end

  describe '#on_failure' do
    subject(:on_failure_callback) do
      failure.on_failure { |value| value << 1 }
             .on_failure(:error) { |value, type| value << type }
             .on_failure(:other_error) { |value| value << 3 }
    end

    let(:array) { [] }
    let(:failure) { described_class.new(array, :error) }

    it 'returns itself' do
      expect(on_failure_callback).to eq failure
    end

    it 'evaluates the given block on failure' do
      on_failure_callback

      expect(array).to eq [1, :error]
    end
  end

  describe '#on_success' do
    subject(:on_success_callback) do
      failure.on_success { |value| value << 1 }
             .on_success(:error) { |value| value << 2 }
             .on_success { raise "This won't ever run" }
    end

    let(:array) { [] }
    let(:failure) { described_class.new(array, :error) }

    it 'returns itself' do
      expect(on_success_callback).to eq failure
    end

    it 'does not evaluate blocks on success' do
      on_success_callback

      expect(array).to eq []
    end
  end

  describe '#to_s' do
    it { expect(failure.to_s).to eq 'Failure("Whoops!")' }
  end
end
