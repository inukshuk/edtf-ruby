require 'date'
require 'time'
require 'set'

require 'edtf/version'
require 'edtf/bitmask'
require 'edtf/period'
require 'edtf/date'
require 'edtf/date_time'
require 'edtf/epoch'
require 'edtf/season'
require 'edtf/interval'
require 'edtf/set'
require 'edtf/parser'
require 'edtf/builder'

# = EDTF-Ruby
#
# Implements the Extended Date/Time Format (EDTF) in ISO 8601-2.
#
# Every EDTF string stands for a period of time (see EDTF::Period):
# dates (EDTF::Date, a Ruby Date), date-times (EDTF::DateTime, a Ruby Time),
# decades and centuries, seasons, intervals, sets and lists.
#
# To parse EDTF strings use `EDTF.parse` or `EDTF()`.
#
module EDTF

  module_function

  def parse(input, options = {})
    parse!(input, options)
  rescue
    nil
  end
  
  def parse!(input, options = {})
    Builder.build(Parser.new(options).parse!(input))
  end

  def legacy?(input)
    parser = Parser.new(warn: false)
    !parser.parse(input).nil? && parser.legacy?
  end
end

module Kernel
  private

  # Converts any value to an EDTF object if possible.
  # Raises an ArgumentError for invalid strings or parse results,
  # and a TypeError for values that cannot be converted at all.
  def EDTF(value)
    case value
    when String
      EDTF.parse!(value)
    when Hash
      EDTF::Builder.build(value)
    when EDTF::Period
      value
    when Time, ::DateTime
      time = value.to_time

      unless (time.utc_offset % 60).zero?
        raise ArgumentError, "offset #{time.strftime('%::z')} is not in whole minutes"
      end

      EDTF::DateTime.new(
        time.year,
        time.month,
        time.day,
        time.hour,
        time.min,
        time.sec + time.subsec,
        offset: time.utc_offset / 60)
    when ::Date
      date = ::Date.jd(value.jd, ::Date::GREGORIAN)
      EDTF::Date.new(date.year, date.month, date.day)
    else
      raise TypeError, "can't convert #{value.class} into EDTF"
    end
  end
end
