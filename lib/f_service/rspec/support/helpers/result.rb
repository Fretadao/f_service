# frozen_string_literal: true

# Methods to mock a FService result from a service call.
module FServiceResultHelpers
  # Create an Fservice result Success or Failure.
  def f_service_result(result, value = nil, types = [])
    if result == :success
      FService::Result::Success.new(value, *Array(types))
    else
      FService::Result::Failure.new(value, *Array(types))
    end
  end

  # Mock a Fservice service call returning a result.
  def mock_service(service, result: :success, value: nil, type: :not_passed, types: [])
    result_types = Array(types)

    if type != :not_passed
      alternative = "mock_service(..., types: [#{type.inspect}])"
      name = 'mock_service'
      FService.deprecate_argument_name(name: name, argument_name: :type, alternative: alternative, from: caller[0])
      result_types = Array(type)
    end

    service_result = f_service_result(result, value, result_types)
    allow(service).to receive(:call).and_return(service_result)
  end
end

RSpec.configure do |config|
  config.include FServiceResultHelpers
end
