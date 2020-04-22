# frozen_string_literal: true

require_relative 'result/base'
require_relative 'result/failure'
require_relative 'result/success'

module FService
  # Abstract base class for services.
  # It provides the basic interface to return and handle results.
  #
  # @abstract
  class Base
    # Initializes and runs a new service.
    #
    # @example
    #   User::UpdateName.(user: user, new_name: new_name)
    #   # or
    #   User::UpdateName.call(user: user, new_name: new_name)
    #
    # @note this method shouldn't be overridden in the subclasses
    # @return [FService::Result::Success, FService::Result::Failure]
    def self.call(*params)
      result = new(*params).run
      raise(FService::Error, 'Services must return a Result') unless result.is_a? Result::Base

      result
    end

    # This method is where the main work of your service must be.
    # It is called after initilizing the service and should return
    # an FService::Result.
    #
    # @example
    #   class User::UpdateName < FService::Base
    #     def initialize(user:, new_name:)
    #       @user = user
    #       @new_name = new_name
    #     end
    #
    #     def run
    #       return failure('Missing user') if user.nil?
    #
    #       if @user.update(name: @new_name)
    #         success(status: 'User successfully updated!', data: user)
    #       else
    #         failure(status: 'User could not be updated.', data: user.errors)
    #       end
    #     end
    #   end
    #
    # @note this method SHOULD be overridden in the subclasses
    # @return [FService::Result::Success, FService::Result::Failure]
    def run
      raise NotImplementedError, 'Services must implement #run'
    end

    # Returns a successful operation.
    # You'll probably want to return this inside {#run}.
    #
    #
    # @example
    #   class User::ValidateAge < FService::Base
    #     def initialize(age:)
    #       @age = age
    #     end
    #
    #     def run
    #       return failure(status: 'No age given!', data: @age) if age.blank?
    #       return failure(status: 'Too young!', data: @age) if age < 18
    #
    #       success(status: 'Valid age.', data: @age)
    #     end
    #   end
    #
    # @return [FService::Result::Success] - a successful operation
    def success(data = nil)
      FService::Result::Success.new(data)
    end

    # Returns a failed operation.
    # You'll probably want to return this inside {#run}.
    # @example
    #   class User::ValidateAge < FService::Base
    #     def initialize(age:)
    #       @age = age
    #     end
    #
    #     def run
    #       return failure(status: 'No age given!', data: @age) if age.blank?
    #       return failure(status: 'Too young!', data: @age) if age < 18
    #
    #       success(status: 'Valid age.', data: @age)
    #     end
    #   end
    #
    # @return [FService::Result::Failure] - a failed operation
    def failure(data = nil)
      FService::Result::Failure.new(data)
    end

    # Return either {FService::Result::Failure Success} or {FService::Result::Failure Failure}
    # given the condition.
    #
    # @example
    #   class YearIsLeap < FService::Base
    #     def initialize(year:)
    #       @year = year
    #     end
    #
    #     def run
    #       return failure(status: 'No year given!', data: @year) if @year.nil?
    #
    #       result(leap?, @year)
    #     end
    #
    #     private
    #
    #     def leap?
    #       ((@year % 4).zero? && @year % 100 != 0) || (@year % 400).zero?
    #     end
    #   end
    #
    # @return [FService::Result::Success, FService::Result::Failure]
    def result(condition, data = nil)
      condition ? success(data) : failure(data)
    end
  end
end
