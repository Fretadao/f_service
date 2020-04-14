# frozen_string_literal: true

require_relative 'result/base'
require_relative 'result/failure'
require_relative 'result/success'

module FService
  class Base
    def self.call(*params)
      result = new(*params).run
      raise(FService::Error, 'Services must return a Result') unless result.is_a? Result::Base

      result
    end

    def success(data = nil)
      FService::Result::Success.new(data)
    end

    def failure(data = nil)
      FService::Result::Failure.new(data)
    end

    def result(condition, data = nil)
      condition ? success(data) : failure(data)
    end
  end
end
