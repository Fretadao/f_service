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
      #
      #
      # @example
      #   # Suppose that User::Update returns an FService::Result
      #
      #   log_errors(user) unless User::Update.(user: user).successful?
      def successful?
        true
      end

      # Returns false.
      #
      #
      # @example
      #   # Suppose that User::Update returns an FService::Result
      #
      #   log_errors(user) if User::Update.(user: user).failed?
      def failed?
        false
      end

      # (see #value)
      def value!
        value
      end

      # Successful operations do not have error.
      #
      # @return [nil]
      def error
        nil
      end

      # @param [Block]
      def then
        yield value
      end

      # Outputs a string representation of the object
      #
      #
      # @example
      #   puts FService::Result::Success.new("Yay!")
      #   # => Success("Yay!")
      #
      # @return [String] the object's string representation
      def to_s
        value.nil? ? 'Success()' : "Success(#{value.inspect})"
      end
    end
  end
end
