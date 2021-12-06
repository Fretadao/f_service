# frozen_string_literal: true

module FService
  # Includes representations of operations that can be successful or failed.
  module Result
    # Abstract base class for Result::Success and Result::Failure.
    #
    # @abstract
    class Base
      UNHANDLED_OPTION = { unhandled: true }.freeze

      %i[initialize and_then successful? failed? value value! error].each do |method_name|
        define_method(method_name) do |*_args|
          raise NotImplementedError, "called #{method_name} on class Result::Base"
        end
      end

      # You usually shouldn't call this directly. See {FService::Base#Failure} and {FService::Base#Success}.
      def initialize
        @handled = false
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
      # Can receive one or more types to be checked before running the given block.
      #
      # @example
      #   class UsersController < BaseController
      #     def update
      #       User::Update.(user: user)
      #                   .on_success(:type, :type2) { return json_success({ status: :ok }) } # run only if type matches
      #                   .on_success(unhandled: true) { |value| return json_success(value) }
      #                   .on_failure(unhandled: true) { |error| return json_error(error) } # this won't run
      #     end
      #
      #     private
      #
      #     def user
      #       @user ||= User.find_by!(slug: params[:slug])
      #     end
      #   end
      #
      # @yieldparam value value of the failure object
      # @yieldparam type type of the failure object
      # @return [Success, Failure] the original Result object
      # @api public
      def on_success(*target_types)
        old_callback_any_matching_warn(method_name: __method__, from: caller[0]) if target_types.empty?

        if successful? && unhandled? && expected_type?(target_types)
          yield(*to_ary)
          @handled = true
          freeze
        end

        self
      end

      # This hook runs if the result is failed.
      # Can receive one or more types to be checked before running the given block.
      #
      # @example
      #   class UsersController < BaseController
      #     def update
      #       User::Update.(user: user)
      #                   .on_success(:unhandled: true) { |value| return json_success(value) } # this won't run
      #                   .on_failure(:type, :type2) { |error| return json_error(error) } # runs only if type matches
      #                   .on_failure(:unhandled: true) { |error| return json_error(error) }
      #     end
      #
      #     private
      #
      #     def user
      #       @user ||= User.find_by!(slug: params[:slug])
      #     end
      #   end
      #
      # @yieldparam value value of the failure object
      # @yieldparam type type of the failure object
      # @return [Success, Failure] the original Result object
      # @api public
      def on_failure(*target_types)
        old_callback_any_matching_warn(method_name: __method__, from: caller[0]) if target_types.empty?

        if failed? && unhandled? && expected_type?(target_types)
          yield(*to_ary)
          @handled = true
          freeze
        end

        self
      end

      # Splits the result object into its components.
      #
      # @return [Array] value and type of the result object
      def to_ary
        data = successful? ? value : error

        [data, type]
      end

      private

      def handled?
        @handled
      end

      def unhandled?
        !handled?
      end

      def expected_type?(target_types)
        target_types.empty? || given_unhandled_option?(target_types) ? true : target_types.include?(type)
      end

      def given_unhandled_option?(target_types)
        target_types.first == UNHANDLED_OPTION
      end

      def old_callback_any_matching_warn(method_name:, from:)
        FService.deprecate!(
          name: "#{self.class}##{method_name} without target type",
          alternative: "#{self.class}##{method_name}(unhandled: true)",
          from: from
        )
      end
    end
  end
end
