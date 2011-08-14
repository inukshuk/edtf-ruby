
require 'date'
autoload :Rational, 'rational'

require 'forwardable'

require 'edtf/version'
require 'edtf/uncertainty'
require 'edtf/seasons'
require 'edtf/date'
require 'edtf/century'
require 'edtf/interval'
require 'edtf/parser'
require 'edtf/extensions'

# module EDTF
#   
#   def self.parse(string)
#     case string.to_s
#     when Interval::PATTERN
#       Interval.parse(string)
#     when Duration::PATTERN
#       Duration.parse(string)
#     when Century::PATTERN
#       Century.parse(string)
#     else
#       DateTime.edtf(string)
#     end
#   end
#   
# end