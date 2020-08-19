# frozen_string_literal: true

module FService
  # Includes representations of operations that can be successful or failed.
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
      # @deprecated Use {#on_success} and/or {#on_failure} instead.
      # @api public
      def on(success:, failure:)
        FService.deprecate!(
          name: "#{self.class}##{__method__}",
          alternative: '#on_success and/or #on_failure'
        )

        if successful?
          success.call(value)
        else
          failure.call(error)
        end
      end

      # This hook runs if the result is successful.
      #
      # @example
      #   class UsersController < BaseController
      #     def update
      #       User::Update.(user: user)
      #                   .on_success { |value| return json_success(value) }
      #                   .on_failure { |error| return json_error(error) } # this won't run
      #     end
      #
      #     private
      #
      #     def user
      #       @user ||= User.find_by!(slug: params[:slug])
      #     end
      #   end
      #
      # @yieldparam [Success] value the success value
      # @return [Success, Failure] the original Result object
      # @api public
      def on_success(target_type = nil)
        yield(value) if successful? && expected_type?(target_type)

        self
      end

      # This hook runs if the result is failed.
      #
      # @example
      #   class UsersController < BaseController
      #     def update
      #       User::Update.(user: user)
      #                   .on_success { |value| return json_success(value) } # this won't run
      #                   .on_failure { |error| return json_error(error) }
      #     end
      #
      #     private
      #
      #     def user
      #       @user ||= User.find_by!(slug: params[:slug])
      #     end
      #   end
      #
      # @yieldparam [Failure] failure the failure value
      # @return [Success, Failure] the original Result object
      # @api public
      def on_failure(target_type = nil)
        yield(error) if failed? && expected_type?(target_type)

        self
      end

      private

      # @api private
      def expected_type?(target_type)
        type == target_type || target_type.nil?
      end
    end
  end
end
