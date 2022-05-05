# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService::Result::Failure do
  describe 'initialize' do
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
  end

  describe '#on_failure' do
    describe 'return' do
      subject(:on_failure_callback) { failure.on_failure(unhandled: true) { 'some recovering' } }

      let(:failure) { described_class.new([], :error) }

      it 'returns itself' do
        expect(on_failure_callback).to eq failure
      end
    end

    describe 'callback matching' do
      context 'when no type is especified' do
        subject(:on_failure_callback) { failure.on_failure { |array| array << "That's no moon" } }

        let(:array) { [] }
        let(:failure) { described_class.new(array, :error) }

        before { allow(FService).to receive(:deprecate!) }

        it 'handles the error' do
          expect { on_failure_callback }.to change { array }.from([]).to(["That's no moon"])
        end
      end

      context 'when type is especified' do
        subject(:on_failure_callback) do
          failure
            .on_failure(:error) { |array, type| array << type }
            .on_failure(:other_error) { |array| array << 3 }
            .on_failure(unhandled: true) { |array| array << "That's no moon" }
        end

        let(:array) { [] }
        let(:failure) { described_class.new(array, type) }

        context 'and no type matches with error type' do
          let(:type) { :unknown_error }

          it 'evaluates the block wich matches without specifying error' do
            on_failure_callback

            expect(array).to eq ["That's no moon"]
          end

          it 'freezes the result' do
            expect(on_failure_callback).to be_frozen
          end
        end

        context 'and some type matches with error type' do
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
  end

  describe '#on_success' do
    subject(:on_success_callback) do
      failure.on_success(unhandled: true) { |value| value << 1 }
             .on_success(:error) { |value| value << 2 }
             .on_success(unhandled: true) { raise "This won't ever run" }
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
    subject(:failure) { described_class.new('Whoops!') }

    it { expect(failure.to_s).to eq 'Failure("Whoops!")' }
  end
end
