# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :have_failed_with do |expected|
  match do |actual|
    matched = actual.is_a?(FService::Result::Failure) && actual.type == expected

    matched &&= actual.error == @expected_error if defined?(@expected_error)

    matched
  end

  chain :and_error do |expected_error|
    @expected_error = expected_error
  end

  failure_message do |actual|
    if actual.is_a?(FService::Result::Failure)
      message = "expected failure's type '#{actual.type.inspect}' to be equal '#{expected.inspect}'"
      if defined?(@expected_error)
        has_description = @expected_error.respond_to?(:description)
        message += " and error '#{actual.error.inspect}' to be "
        message += has_description ? @expected_error.description : "equal '#{@expected_error.inspect}'"
      end

      message
    else
      "result '#{actual.inspect}' is not a Failure object"
    end
  end
end

RSpec::Matchers.define :have_succeed_with do |expected|
  match do |actual|
    matched = actual.is_a?(FService::Result::Success) && actual.type == expected

    matched &&= values_match?(@expected_value, actual.value) if defined?(@expected_value)

    matched
  end

  chain :and_value do |expected_value|
    @expected_value = expected_value
  end

  failure_message do |actual|
    if actual.is_a?(FService::Result::Success)
      message = "expected success's type '#{actual.type.inspect}' to be equal '#{expected.inspect}'"
      if defined?(@expected_value)
        has_description = @expected_value.respond_to?(:description)
        message += " and value '#{actual.value.inspect}' to be "
        message += has_description ? @expected_value.description : "equal '#{@expected_value.inspect}'"
      end

      message
    else
      "result '#{actual.inspect}' is not a Success object"
    end
  end
end
