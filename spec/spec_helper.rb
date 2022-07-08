begin
  require 'simplecov'
rescue LoadError
  # ignore
end

begin
  require 'debug'
rescue LoadError
  # ignore
end

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'edtf'
