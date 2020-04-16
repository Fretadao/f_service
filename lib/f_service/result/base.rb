# frozen_string_literal: true

module FService
  module Result
    # Abstract base class for Result::Success and Result::Failure.
    #
    # @abstract
    class Base
      %i[initialize then successful? failed? value value! error].each do |method_name|
        define_method(method_name) do |*_args|
          raise NotImplementedError, "called #{method_name} on class Result::Base"
        end
      end

      # "Pattern matching"-like method for results.
      # It will run the success path if Result is a Success.
      # Otherwise, it will run the failure path.
      #
      #
      # @example
      #   class UsersController < BaseController
      #     def update
      #       User::Update.(user: user).on(
      #         success: ->(value) { return json_success(value) },
      #         failure: ->(error) { return json_error(error) }
      #       )
      #     end
      #
      #     private
      #
      #     def user
      #       @user ||= User.find_by!(slug: params[:slug])
      #     end
      #   end
      #
      # @param success [#call] a lambda (or anything that responds to #call) to run on success
      # @param failure [#call] a lambda (or anything that responds to #call) to run on failure
      # @api public
      def on(success:, failure:)
        if successful?
          success.call(value)
        else
          failure.call(error)
        end
      end
    end
  end
end
