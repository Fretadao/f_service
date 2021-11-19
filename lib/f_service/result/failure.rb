# frozen_string_literal: true

require_relative 'base'
require_relative '../errors'

module FService
  module Result
    # Represents a value of a failed operation.
    # The error field can contain any information you want.
    #
    # @!attribute [r] error
    #   @return [Object] the provided error for the result
    # @!attribute [r] type
    #   @return [Object] the provided type for the result. Defaults to nil.
    # @api public
    class Failure < Result::Base
      attr_reader :error, :type

      # Creates a failed operation.
      # You usually shouldn't call this directly. See {FService::Base#Failure}.
      #
      # @param error [Object] failure value.
      def initialize(error, type = nil)
        @error = error
        @type = type
      end

      # Returns false.
      #
      #
      # @example
      #   # Suppose that User::Update returns an FService::Result
      #
      #   log_errors(user) unless User::Update.(user: user).successful?
      def successful?
        false
      end

      # Returns true.
      #
      #
      # @example
      #   # Suppose that User::Update returns an FService::Result
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

      # Returns the current error to the given block.
      # Use this to chain multiple service calls (since all services return Results).
      # It works just like the `.and_then` method, but only runs if the result is a Failure.
      #
      #
      # @example
      #   class UpdateUserOnExternalService
      #     attribute :user_params
      #
      #     def run
      #       check_api_status
      #         .and_then { update_user }
      #         .or_else { create_update_worker }
      #     end
      #
      #     private
      #     # some code
      #   end
      #
      # @yieldparam error pass {#error} to a block
      # @yieldparam type pass {#type} to a block
      def catch
        yield(*to_ary)
      end

      alias or_else catch

      # Returns itself to the given block.
      # Use this to chain multiple service calls (since all services return Results).
      # It will short circuit your service call chain.
      #
      #
      # @example
      #   class UsersController < BaseController
      #     def create
      #       result = User::Create.(user_params) # if this fails the following calls won't run
      #                            .and_then { |user| User::SendWelcomeEmail.(user: user) }
      #                            .and_then { |user| User::Login.(user: user) }
      #
      #       if result.successful?
      #         json_success(result.value)
      #       else
      #         json_error(result.error)
      #       end
      #     end
      #   end
      #
      # @return [self]
      def and_then
        self
      end
      alias then and_then

      # Outputs a string representation of the object
      #
      #
      # @example
      #   puts FService::Result::Failure.new("Oh no!")
      #   # => Failure("Oh no!")
      #
      # @return [String] the object's string representation
      def to_s
        error.nil? ? 'Failure()' : "Failure(#{error.inspect})"
      end
    end
  end
end
