require 'bundler/gem_tasks'
require 'rake/clean'

$:.unshift(File.join(File.dirname(__FILE__), './lib'))
require 'edtf/version'

task :default => [:spec, :cucumber]

desc 'Run an IRB session with EDTF loaded'
task :console, [:script] do |t,args|
  ARGV.clear

  require 'irb'
  require 'edtf'

  IRB.conf[:SCRIPT] = args.script
  IRB.start
end

desc 'Generates the parser'
task :racc do
  sh 'bundle exec racc -o lib/edtf/parser.rb lib/edtf/parser.y'
end

desc 'Generates the parser with debug information'
task :racc_debug do
  sh 'bundle exec racc -v -t -o lib/edtf/parser.rb lib/edtf/parser.y'
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber)

CLEAN.include('lib/edtf/parser.rb')
CLEAN.include('lib/edtf/parser.output')
CLOBBER.include('pkg')
