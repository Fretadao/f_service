# frozen_string_literal: true

require 'f_service'

class IsLeap < FService::Base
  def initialize(year:)
    @year = year
  end

  def run
    return failure(status: 'No year given!', data: @year) if @year.nil?

    success(leap? ? 'Yes' : 'No')
  end

  private

  def leap?
    (((@year % 4).zero? && @year % 100 != 0) || (@year % 400).zero?)
  end
end

class AddEmotion < FService::Base
  def initialize(str)
    @str = str
  end

  def run
    success("#{@str}!")
  end
end

class AddDoubt < FService::Base
  def initialize(bool)
    @bool = bool
  end

  def run
    success("#{@bool}?")
  end
end

puts IsLeap.call(year: 2020)
           .then(&AddEmotion)
           .then(&AddDoubt)
           .value!
