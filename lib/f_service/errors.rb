# frozen_string_literal: true

module FService
  # General FService error
  class Error < StandardError; end

  module Result
    # Fservice::Result related error
    class Error < Error; end
  end
end
