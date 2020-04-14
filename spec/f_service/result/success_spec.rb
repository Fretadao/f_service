# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService::Result::Success do
  subject(:success) { described_class.new('Yay!') }

  it { expect(success).to be_a described_class }
  it { expect(success).to be_successful }
  it { expect(success.value).to eq('Yay!') }
  it { expect(success.error).to eq(nil) }
  it { expect(success.value!).to eq('Yay!') }

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
