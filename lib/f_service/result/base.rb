# frozen_string_literal: true

module FService
  # Includes representations of operations that can be successful or failed.
  module Result
    # Abstract base class for Result::Success and Result::Failure.
    #
    # @abstract
    class Base
      %i[initialize and_then successful? failed? value value! error].each do |method_name|
        define_method(method_name) do |*_args|
          raise NotImplementedError, "called #{method_name} on class Result::Base"
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
      # @yieldparam value value of the failure object
      # @yieldparam type type of the failure object
      # @return [Success, Failure] the original Result object
      # @api public
      def on_success(*target_types)
        yield(*to_ary) if successful? && expected_type?(target_types)

        self
      end

      # This hook runs if the result is failed.
      # Can receive one or more types to be checked before running the given block.
      #
      # @example
      #   class UsersController < BaseController
      #     def update
      #       User::Update.(user: user)
      #                   .on_success { |value| return json_success(value) } # this won't run
      #                   .on_failure(:type, :type2) { |error| return json_error(error) } # runs only if type matches
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
      # @yieldparam value value of the failure object
      # @yieldparam type type of the failure object
      # @return [Success, Failure] the original Result object
      # @api public
      def on_failure(*target_types)
        yield(*to_ary) if failed? && expected_type?(target_types)

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

      def expected_type?(target_types)
        target_types.include?(type) || target_types.empty?
      end
    end
  end
end
