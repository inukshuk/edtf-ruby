require 'date'
require 'time'

autoload :Rational, 'rational'

require 'forwardable'
require 'enumerator'
require 'set'

require 'active_support'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/date_time/calculations'
require 'active_support/core_ext/time/calculations'

require 'active_support/core_ext/date/conversions'

require 'edtf/compatibility'

require 'edtf/version'
require 'edtf/bitmask'
require 'edtf/uncertainty'
require 'edtf/date'
require 'edtf/date_time'
require 'edtf/epoch'
require 'edtf/season'
require 'edtf/interval'
require 'edtf/set'
require 'edtf/unknown'
require 'edtf/parser'
require 'edtf/extensions'

# = EDTF-Ruby
#
# This module extends the Ruby date/time classes to support the Extended
# Date/Time Format (EDTF). See the `EDTF::ExtendedDate` module for an
# overview of the features added to the Ruby `Date` class.
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
    Parser.new(options).parse!(input)
  end

  def legacy?(input)
    parser = Parser.new(warn: false)
    !parser.parse(input).nil? && parser.legacy?
  end
end

module Kernel
  private

  # Converts value to an EDTF object:
  # strings are parsed, times become date-times,
  # dates and other EDTF objects are returned unchanged.
  def EDTF(value)
    case value
    when String
      EDTF.parse!(value)
    when Time
      value.to_datetime
    when Date, EDTF::Season, EDTF::Epoch, EDTF::Interval, EDTF::Set, EDTF::Unknown
      value
    else
      raise TypeError, "can't convert #{value.class} into EDTF"
    end
  end
end
