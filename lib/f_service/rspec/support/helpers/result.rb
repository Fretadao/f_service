# frozen_string_literal: true

# Methods to mock a FService result from a service call.
module FServiceResultHelpers
  # Results a mock can describe.
  RESULTS = %i[success failure].freeze

  # Create an Fservice result Success or Failure.
  #
  # @raise [ArgumentError] when the result is neither :success nor :failure
  def f_service_result(result, value = nil, types = [])
    raise ArgumentError, "result must be :success or :failure, got #{result.inspect}" unless RESULTS.include?(result)

    if result == :success
      FService::Result::Success.new(value, Array(types))
    else
      FService::Result::Failure.new(value, Array(types))
    end
  end

  # Mock a Fservice service call returning a result.
  #
  # Every call to the mocked service runs the service's real initializer with the call's
  # arguments, so a call the service would reject fails with ArgumentError. The service's
  # #run is never executed. A double passed as the service is not verified.
  #
  # @raise [ArgumentError] when the result is neither :success nor :failure
  def mock_service(service, result: :success, value: nil, types: [])
    service_result = f_service_result(result, value, Array(types))

    allow(service).to receive(:call) do |*args, **kwargs|
      # allocate skips .new, so a spec that stubs .new does not interfere with the verification
      service.allocate.send(:initialize, *args, **kwargs) if service.is_a?(Class)
      service_result
    end
  end
end

RSpec.configure do |config|
  config.include FServiceResultHelpers
end
