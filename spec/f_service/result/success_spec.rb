# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService::Result::Success do
  subject(:success) { described_class.new('Yay!') }

  it { expect(success).to be_a described_class }
  it { expect(success).to be_successful }
  it { expect(success).not_to be_failed }
  it { expect(success.value).to eq('Yay!') }
  it { expect(success.error).to eq(nil) }
  it { expect(success.value!).to eq('Yay!') }

  describe '#on' do
    context 'when matching results' do
      subject(:success_match) do
        described_class.new('Yay!').on(
          success: ->(value) { return value + '!' },
          failure: ->(_error) { raise "This wont't ever run" }
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

  describe '#to_s' do
    it { expect(success.to_s).to eq 'Success("Yay!")' }
  end
end
