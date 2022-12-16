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
    class << self
      # Initializes and runs a new service.
      #
      # @example
      #   User::UpdateName.(user: user, new_name: new_name)
      #   # or
      #   User::UpdateName.call(user: user, new_name: new_name)
      #
      # @note this method shouldn't be overridden in the subclasses
      # @return [Result::Success, Result::Failure]
      def call(*args)
        result = new(*args).run
        raise(FService::Error, 'Services must return a Result') unless result.is_a? Result::Base

        result
      end

      ruby2_keywords :call if respond_to?(:ruby2_keywords, true)

      # Allows running a service without explicit giving params.
      # This is useful when chaining services or mapping inputs to be processed.
      #
      # @example
      #   # Assuming all classes here subclass FService::Base:
      #
      #   User::Create
      #     .and_then(&User::Login)
      #     .and_then(&SendWelcomeEmail)
      #
      #   # Mapping inputs:
      #
      #   [{ n:1 }, { n: 2 }].map(&DoubleNumber).map(&:value)
      #   # => [2, 4]
      #
      # @return [Proc]
      def to_proc
        proc { |args| call(**args) }
      end
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
    #       return Failure(:missing_user) if user.nil?
    #
    #       if @user.update(name: @new_name)
    #         Success(:created, data: user)
    #       else
    #         Failure(:creation_failed, data: user.errors)
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
        alternative: '#Success',
        from: caller[0]
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
    #     Success()
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
    # @param type the Result type
    # @param data the result value
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
    #     Failure()
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
    # @param type the Result type
    # @param data the result value
    # @return [Result::Failure] a failed result
    def Failure(type = nil, data: nil)
      Result::Failure.new(data, type)
    end

    # Converts a boolean to a Result.
    # Truthy values map to Success, and falsey values map to Failures.
    # You can optionally provide a type for the result.
    # The result value defaults as the evaluated value of the given block.
    # If you want another value you can pass it through the `data:` argument.
    #
    # @example
    #   class CheckMathWorks < FService::Base
    #     def run
    #       Check(:math_works) { 1 < 2 }
    #       # => #<Success @value=true, @type=:math_works>
    #
    #       Check(:math_works) { 1 > 2 }
    #       # => #<Failure @error=false, @type=:math_works>
    #
    #       Check(:math_works, data: 1 + 2) { 1 > 2 }
    #       # => #<Failure @type=:math_works, @error=3>
    #     end
    #
    #       Check(:math_works, data: 1 + 2) { 1 < 2 }
    #       # => #<Success @type=:math_works, @value=3>
    #     end
    #   end
    #
    # @param type the Result type
    # @return [Result::Success, Result::Failure] a Result from the boolean expression
    def Check(type = nil, data: nil)
      res = yield

      final_data = data || res

      res ? Success(type, data: final_data) : Failure(type, data: final_data)
    end

    # If the given block raises an exception, it wraps it in a Failure.
    # Otherwise, maps the block value in a Success object.
    # You can specify which exceptions to watch for.
    # It's possible to provide a type for the result too.
    #
    # @example
    #   class IHateEvenNumbers < FService::Base
    #     def run
    #       Try(:rand_int) do
    #         n = rand(1..10)
    #         raise "Yuck! It's a #{n}" if n.even?
    #
    #         n
    #       end
    #     end
    #   end
    #
    #   IHateEvenNumbers.call
    #   # => #<Success @value=9, @type=:rand_int>
    #
    #   IHateEvenNumbers.call
    #   # => #<Failure @error=#<RuntimeError: Yuck! It's a 4>, @type=:rand_int>
    #
    # @param type the Result type
    # @param catch the exception list to catch
    # @return [Result::Success, Result::Failure] a result from the boolean expression
    def Try(type = nil, catch: StandardError)
      res = yield

      Success(type, data: res)
    rescue *catch => e
      Failure(type, data: e)
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
        alternative: '#Failure',
        from: caller[0]
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
    # @deprecated Use {#Check} instead.
    # @return [Result::Success, Result::Failure]
    def result(condition, data = nil)
      FService.deprecate!(
        name: "#{self.class}##{__method__}",
        alternative: '#Check',
        from: caller[0]
      )

      condition ? success(data) : failure(data)
    end
  end
end
