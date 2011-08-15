#--
# EDTF-Ruby
# Copyright 2011 Sylvester Keil. All rights reserved.
#++

require 'date'
autoload :Rational, 'rational'

require 'forwardable'

require 'edtf/compatibility'

require 'edtf/version'
require 'edtf/uncertainty'
require 'edtf/seasons'
require 'edtf/date'
require 'edtf/interval'
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
  
  def parse(input, options = {})
    ::Date.edtf(input, options)
  end
  
  module_function :parse
  
end