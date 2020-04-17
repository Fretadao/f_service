# frozen_string_literal: true

require_relative 'base'
require_relative '../errors'

module FService
  module Result
    # Represents a value of a failed operation.
    #
    # @api public
    class Failure < Result::Base
      # Returns the provided error
      attr_reader :error

      # Creates a failed operation.
      # You usually shouldn't call this directly. See {FService::Base#failure}.
      #
      # @param error [Object] failure value.
      def initialize(error)
        @error = error
        freeze
      end

      # Returns false.
      #
      #
      # @example
      #   # Suppose that User::Update returns a FService::Result
      #
      #   log_errors(user) unless User::Update.(user: user).successful?
      def successful?
        false
      end

      # Returns true.
      #
      #
      # @example
      #   # Suppose that User::Update returns a FService::Result
      #
      #   log_errors(user) if User::Update.(user: user).failed?
      def failed?
        true
      end

      # Failed operations do not have value.
      def value
        nil
      end

      # Raises an exception if called.
      # (see #value)
      def value!
        raise Result::Error, 'Failure objects do not have value'
      end

      def then
        self
      end
    end
  end
end
