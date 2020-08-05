# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService::Result::Success do
  subject(:success) { described_class.new('Yay!') }

  it { expect(success).to be_a described_class }
  it { expect(success).to be_successful }
  it { expect(success).not_to be_failed }
  it { expect(success.value).to eq('Yay!') }
  it { expect(success.type).to eq(nil) }
  it { expect(success.error).to eq(nil) }
  it { expect(success.value!).to eq('Yay!') }

  context 'when defining a type' do
    subject(:success) { described_class.new('Yay!', :ok) }

    it { expect(success.type).to eq(:ok) }
  end

  describe '#on' do
    context 'when matching results' do
      subject(:success_match) do
        described_class.new('Yay!').on(
          success: ->(value) { return value + '!' },
          failure: ->(_error) { raise "This won't ever run" }
        )
      end

      it 'runs on the success path' do
        expect(success_match).to eq('Yay!!')
      end
    end

    context 'when chaining results' do
      subject(:chain) do
        described_class.new('Yay!')
                       .then { |value| described_class.new(value + ' It') }
                       .then { |value| described_class.new(value + ' works!') }
      end

      it { expect(chain).to be_successful }

      it 'chains successful results' do
        expect(chain.value).to eq('Yay! It works!')
      end
    end
  end

  describe '#on_success' do
    subject(:on_success_callback) do
      success.on_success { |value| value << 1 }
    end

    let(:array) { [] }
    let(:success) { described_class.new(array) }

    it 'returns itself' do
      expect(on_success_callback).to eq success
    end

    it 'evaluates the given block on success' do
      on_success_callback

      expect(array).to eq [1]
    end
  end

  describe '#on_failure' do
    subject(:on_failure_callback) do
      success.on_failure { |value| value << 1 }
             .on_failure { raise "This won't ever run" }
    end

    let(:array) { [] }
    let(:success) { described_class.new(array) }

    it 'returns itself' do
      expect(on_failure_callback).to eq success
    end

    it 'does not evaluate the given block on failure' do
      on_failure_callback

      expect(array).to eq []
    end
  end

  describe '#to_s' do
    it { expect(success.to_s).to eq 'Success("Yay!")' }
  end
end
