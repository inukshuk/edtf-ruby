require 'date'

require 'edtf/version'
require 'edtf/duration'
require 'edtf/century'
require 'edtf/parser'

class Date
  include EDTF::Century
end