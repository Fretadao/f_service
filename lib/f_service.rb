# frozen_string_literal: true

require_relative 'f_service/base'

# A small, monad-based service class
#
# @api public
module FService
  # Marks a method as deprecated
  #
  # @api private
  def self.deprecate!(name:, alternative:, from: nil)
    warn_message = ["\n[DEPRECATED] #{name} is deprecated; "]
    warn_message << ["called from #{from}; "] unless from.nil?
    warn_message << "use #{alternative} instead. "
    warn_message << 'It will be removed on the next release.'

    warn warn_message.join("\n")
  end

  # Marks an argument as deprecated
  #
  # @api private
  def self.deprecate_argument_name(name:, argument_name:, alternative:, from: nil)
    warn_message = ["\n[DEPRECATED] #{name} passing #{argument_name.inspect} is deprecated; "]
    warn_message << ["called from #{from}; "] unless from.nil?
    warn_message << "use #{alternative} instead. "
    warn_message << 'It will be removed on the next release.'

    warn warn_message.join("\n")
  end
end
