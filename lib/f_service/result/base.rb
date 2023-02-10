# frozen_string_literal: true

module FService
  # Includes representations of operations that can be successful or failed.
  module Result
    # Abstract base class for Result::Success and Result::Failure.
    #
    # @abstract
    class Base
      %i[and_then successful? failed? value value! error].each do |method_name|
        define_method(method_name) do |*_args|
          raise NotImplementedError, "called #{method_name} on class Result::Base"
        end
      end

      # You usually shouldn't call this directly. See {FService::Base#Failure} and {FService::Base#Success}.
      def initialize
        @handled = false
        @matching_types = []
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
      def on_success(*target_types, unhandled: false)
        if successful? && unhandled? && expected_type?(target_types, unhandled: unhandled)
          match_types(target_types)
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
      def on_failure(*target_types, unhandled: false)
        if failed? && unhandled? && expected_type?(target_types, unhandled: unhandled)
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

        [data, respond_to?(:type) ? type : @matching_types.first]
      end

      private

      def handled?
        @handled
      end

      def unhandled?
        !handled?
      end

      def expected_type?(target_types, unhandled:)
        if respond_to?(:type)
          target_types.empty? || unhandled || target_types.include?(type)
        else
          target_types.empty? || unhandled || target_types.any? { |target_type| types.include?(target_type) }
        end
      end

      def match_types(target_types)
        @matching_types = if target_types.empty?
                            []
                          elsif respond_to?(:type)
                            type
                          else
                            target_types & types
                          end
      end
    end
  end
end
