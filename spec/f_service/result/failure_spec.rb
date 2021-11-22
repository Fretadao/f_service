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
                                 .and_then { |_value| raise "This won't ever run!" }
      end

      it { expect(chain).to be_failed }

      it 'shorts circuit on failures' do
        expect(chain.error).to eq('This... Fails!')
      end
    end

    context 'when chaining results with a catch block' do
      subject(:chain) do
        FService::Result::Success.new('This...')
                                 .then { |value| described_class.new(value + ' Fails!') }
                                 .catch { |error| described_class.new(error + ' Again!') }
                                 .then { |_value| raise "This won't ever run!" }
      end

      it { expect(chain).to be_failed }

      it 'executes the catch block ' do
        expect(chain.error).to eq('This... Fails! Again!')
      end
    end

    context 'when chaining results with a catch block using the `or` alias' do
      subject(:chain) do
        FService::Result::Success.new('This...')
                                 .then { |value| described_class.new(value + ' Fails!') }
                                 .or_else { |error| described_class.new(error + ' Again!') }
                                 .then { |_value| raise "This won't ever run!" }
      end

      it { expect(chain).to be_failed }

      it 'executes the catch block ' do
        expect(chain.error).to eq('This... Fails! Again!')
      end
    end
  end

  describe '#on_failure' do
    subject(:on_failure_callback) do
      failure.on_failure(:error) { |array, type| array << type }
             .on_failure(:other_error) { |array| array << 3 }
             .on_failure { |array| array << "That's no moon" }
    end

    let(:array) { [] }
    let(:failure) { described_class.new(array, type) }

    describe 'return' do
      let(:type) { :error }

      it 'returns itself' do
        expect(on_failure_callback).to eq failure
      end
    end

    describe 'callback matching' do
      context 'when no type matches with error type' do
        let(:type) { :new_error }

        it 'evaluates the block wich matches without specifying error' do
          on_failure_callback

          expect(array).to eq ["That's no moon"]
        end

        it 'freezes the result' do
          expect(on_failure_callback).to be_frozen
        end
      end

      context 'when some type matches with error type' do
        let(:type) { :error }

        it 'freezes the result' do
          expect(on_failure_callback).to be_frozen
        end

        it 'evaluates only the first given block on failure' do
          on_failure_callback

          expect(array).to eq [:error]
        end
      end
    end
  end

  describe '#on_success' do
    subject(:on_success_callback) do
      failure.on_success { |value| value << 1 }
             .on_success(:error) { |value| value << 2 }
             .on_success { raise "This won't ever run" }
             .on_success(:error, :other_error) { raise 'Chewbacca is a Wookie warrior' }
    end

    let(:array) { [] }
    let(:failure) { described_class.new(array, :error) }

    it 'returns itself' do
      expect(on_success_callback).to eq failure
    end

    it 'keeps the result unfreeze' do
      expect(on_success_callback).not_to be_frozen
    end

    it 'does not evaluate blocks on success' do
      on_success_callback

      expect(array).to eq []
    end
  end

  describe '#or_else' do
    subject(:failure) { described_class.new('User not found', :error) }

    it 'returns the given block result' do
      expect(failure.or_else { |error| "Failure: #{error}" }).to eq('Failure: User not found')
    end
  end

  describe '#and_then' do
    subject(:failure) { described_class.new('Pax', :ok) }

    it 'does not yields the block' do
      expect { |block| failure.and_then(&block) }.not_to yield_control
    end

    it 'returns itself' do
      expect(failure.and_then { 'an error happened' }).to eq(failure)
    end
  end

  describe '#to_s' do
    it { expect(failure.to_s).to eq 'Failure("Whoops!")' }
  end
end
