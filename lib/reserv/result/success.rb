# frozen_string_literal: true

require_relative 'base'

module Reserv
  module Result
    class Success < Result::Base
      attr_reader :value

      def initialize(value)
        @value = value
        freeze
      end

      def successful?
        true
      end

      def failed?
        false
      end

      def value!
        value
      end

      def error
        nil
      end

      def then
        yield value
      end
    end
  end
end
