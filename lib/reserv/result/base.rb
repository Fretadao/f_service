# frozen_string_literal: true

module Reserv
  module Result
    class Base
      %i[initialize then successful? failed? value value! error].each do |method_name|
        define_method(method_name) do |*_args|
          raise NotImplementedError, "called #{method_name} on class Result::Base"
        end
      end

      def on(success:, failure:)
        if successful?
          success.call(value)
        else
          failure.call(error)
        end
      end
    end
  end
end
