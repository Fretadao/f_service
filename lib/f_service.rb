# frozen_string_literal: true

require_relative 'f_service/base'

# A small, monad-based service class
#
# @api public
module FService
  # Mark a method as deprecated
  def self.deprecate!(name:, alternative:)
    warn "[DEPRECATED] #{name} is deprecated; " \
         "use #{alternative} instead. " \
         'It will be removed on the next release.'
  end
end
