# frozen_string_literal: true

module FServiceResultHelpers
  def f_service_result(result, value = nil, type = nil)
    if result == :success
      FService::Result::Success.new(value, type)
    else
      FService::Result::Failure.new(value, type)
    end
  end

  def mock_service(service, result: :success, value: nil, type: nil)
    service_result = f_service_result(result, value, type)
    allow(service).to receive(:call).and_return(service_result)
  end
end

RSpec.configure do |config|
  config.include FServiceResultHelpers
end
