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
# To parse EDTF strings use either `Date.edtf` of `EDTF.parse`.
#
module EDTF

  module_function

  def parse(input, options = {})
    parse!(input, options)
  rescue
    nil
  end
  
  def parse!(input, options = {})
    ::Date.edtf!(input, options)
  end

  def legacy?(input)
    parser = Parser.new(warn: false)
    !parser.parse(input).nil? && parser.legacy?
  end
end
