# frozen_string_literal: true

require_relative 'base'

module FService
  module Result
    # Represents a value of a successful operation.
    #
    # @api public
    class Success < Result::Base
      # Returns the provided value.
      attr_reader :value

      # Creates a successful operation.
      # You usually shouldn't call this directly. See {FService::Base#success}.
      #
      # @param value [Object] success value.
      def initialize(value)
        @value = value
        freeze
      end

      # Returns true.
      def successful?
        true
      end

      # Returns false.
      def failed?
        false
      end

      # (see #value)
      def value!
        value
      end

      # Succesful operations do not have error.
      #
      # @return [nil]
      def error
        nil
      end

      # @param [Block]
      def then
        yield value
      end
    end
  end
end
