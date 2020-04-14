# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService::Result::Failure do
  subject(:failure) { described_class.new('Whoops!') }

  it { expect(failure).to be_a described_class }
  it { expect(failure).to be_failed }
  it { expect(failure).not_to be_successful }
  it { expect(failure.error).to eq('Whoops!') }
  it { expect(failure.value).to eq(nil) }
  it { expect { failure.value! }.to raise_error FService::Result::Error }

  it 'runs on the failure path' do
    expect(
      failure.on(
        success: ->(_value) { raise "This wont't ever run" },
        failure: ->(error) { return error + '!' }
      )
    ).to eq('Whoops!!')
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
