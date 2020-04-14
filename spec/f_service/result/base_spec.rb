# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService::Result::Base do
  let(:test_class) do
    Class.new(described_class) do
      def initialize; end
    end
  end

  it 'raises error on .new call' do
    expect { described_class.new }.to raise_error NotImplementedError, 'called initialize on class Result::Base'
  end

  %i[then successful? failed? value value! error].each do |method_name|
    context 'when subclasses do not override methods' do
      subject(:method_call) { test_class.new.public_send(method_name) }

      it "raises error on '#{method_name}' call" do
        expect { method_call }.to raise_error NotImplementedError, "called #{method_name} on class Result::Base"
      end
    end
  end
end
