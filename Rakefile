
require 'rake/clean'

desc 'Generates the parser'
task :racc do
  system 'bundle exec racc -o lib/edtf/parser.rb lib/edtf/parser.y'
end

desc 'Generates the parser with debug information'
task :racc_debug do
  system 'bundle exec racc -v -t -o lib/edtf/parser.rb lib/edtf/parser.y'
end

desc 'Builds the gem file'
task :build => [:racc] do
  system 'gem build edtf.gemspec'
end

CLEAN.include('lib/edtf/parser.rb')
CLEAN.include('lib/edtf/parser.output')
CLEAN.include('*.gem')
