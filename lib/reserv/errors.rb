# frozen_string_literal: true

module Reserv
  class Error < StandardError; end

  module Result
    class Error < Error; end
  end
end
