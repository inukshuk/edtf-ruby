begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  # ignore
end

require 'edtf'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |file| require file }
