# frozen_string_literal: true

require_relative 'base'

module FService
  module Result
    # Represents a value of a successful operation.
    # The value field can contain any information you want.
    #
    # @!attribute [r] value
    #   @return [Object] the provided value for the result
    # @!attribute [r] types
    #   @return [Object] the provided types for the result. Defaults to nil.
    # @api public
    class Success < Result::Base
      attr_reader :value

      # Creates a successful operation.
      # You usually shouldn't call this directly. See {FService::Base#Success}.
      #
      # @param value [Object] success value.
      def initialize(value, types = [])
        super(types)
        @value = value
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

      # Returns its value to the given block.
      # Use this to chain multiple service calls (since all services return Results).
      #
      #
      # @example
      #   class UsersController < BaseController
      #     def create
      #       result = User::Create.(user_params)
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
      # @yieldparam value pass {#value} to a block
      # @yieldparam types pass {#types} to a block
      def and_then
        yield(*to_ary)
      end

      # See #and_then
      def then(&block)
        FService.deprecate!(name: "#{self.class}##{__method__}", alternative: '#and_then', from: caller[0])

        and_then(&block)
      end

      # Returns itself to the given block.
      # Use this to chain multiple actions or service calls (only valid when they return a Result).
      # It works just like the `.and_then` method, but only runs if service is a Failure.
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
      # @return [self]
      def catch
        self
      end

      alias or_else catch

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
