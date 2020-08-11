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
    # NOTE: We have to make this check since Ruby 2.7 changed
    #       how positional and keywords arguments are treated
    # More info: https://bugs.ruby-lang.org/issues/16157
    all_args = RUBY_VERSION < '2.7' ? '*args' : '...'

    Base.class_eval <<~RUBY, __FILE__, __LINE__ + 1
      # Initializes and runs a new service.
      #
      # @example
      #   User::UpdateName.(user: user, new_name: new_name)
      #   # or
      #   User::UpdateName.call(user: user, new_name: new_name)
      #
      # @note this method shouldn't be overridden in the subclasses
      # @return [Result::Success, Result::Failure]
      def self.call(#{all_args})
        result = new(#{all_args}).run
        raise(FService::Error, 'Services must return a Result') unless result.is_a? Result::Base

        result
      end
    RUBY

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
    # @return [Result::Success, Result::Failure]
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
    # @deprecated Use {#Success} instead.
    # @return [Result::Success] a successful operation
    def success(data = nil)
      FService.deprecate!(
        name: "#{self.class}##{__method__}",
        alternative: '#Success'
      )

      Result::Success.new(data)
    end

    # Returns a successful result.
    # You can optionally specify a type and a value for your result.
    # You'll probably want to return this inside {#run}.
    #
    #
    # @example
    #   def run
    #     Success
    #     # => #<Success @value=nil, @type=nil>
    #
    #     Success(:ok)
    #     # => #<Success @value=nil, @type=:ok>
    #
    #     Success(data: 10)
    #     # => #<Success @value=10, @type=nil>
    #
    #     Success(:ok, data: 10)
    #     # => #<Success @value=10, @type=:ok>
    #   end
    #
    # @return [Result::Success] a successful result
    def Success(type = nil, data: nil)
      Result::Success.new(data, type)
    end

    # Returns a failed result.
    # You can optionally specify a type and a value for your result.
    # You'll probably want to return this inside {#run}.
    #
    #
    # @example
    #   def run
    #     Failure
    #     # => #<Failure @error=nil, @type=nil>
    #
    #     Failure(:not_a_number)
    #     # => #<Failure @error=nil, @type=:not_a_number>
    #
    #     Failure(data: "10")
    #     # => #<Failure @error="10", @type=nil>
    #
    #     Failure(:not_a_number, data: "10")
    #     # => #<Failure @error="10", @type=:not_a_number>
    #   end
    #
    # @return [Result::Failure] a failed result
    def Failure(type = nil, data: nil)
      Result::Failure.new(data, type)
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
    # @deprecated Use {#Failure} instead.
    # @return [Result::Failure] a failed operation
    def failure(data = nil)
      FService.deprecate!(
        name: "#{self.class}##{__method__}",
        alternative: '#Failure'
      )

      Result::Failure.new(data)
    end

    # Return either {Result::Failure Success} or {Result::Failure Failure}
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
    # @return [Result::Success, Result::Failure]
    def result(condition, data = nil)
      condition ? success(data) : failure(data)
    end
  end
end
