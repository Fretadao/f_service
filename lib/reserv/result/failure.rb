# frozen_string_literal: true

require_relative 'base'
require_relative '../errors'

module Reserv
  module Result
    class Failure < Result::Base
      attr_reader :error

      def initialize(error)
        @error = error
        freeze
      end

      def successful?
        false
      end

      def failed?
        true
      end

      def value
        nil
      end

      def value!
        raise Result::Error, 'Failure objects do not have value'
      end

      def then
        self
      end
    end
  end
end
