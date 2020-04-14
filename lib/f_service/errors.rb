# frozen_string_literal: true

module FService
  class Error < StandardError; end

  module Result
    class Error < Error; end
  end
end
