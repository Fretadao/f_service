# frozen_string_literal: true

# Methods to mock a FService result from a service call.
module FServiceResultHelpers
  # Create an Fservice result Success or Failure.
  def f_service_result(result, value = nil, types = [])
    if result == :success
      FService::Result::Success.new(value, Array(types))
    else
      FService::Result::Failure.new(value, Array(types))
    end
  end

  # Mock a Fservice service call returning a result.
  def mock_service(service, result: :success, value: nil, types: [])
    service_result = f_service_result(result, value, Array(types))
    allow(service).to receive(:call).and_return(service_result)
  end
end

RSpec.configure do |config|
  config.include FServiceResultHelpers
end
