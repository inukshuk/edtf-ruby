
require 'bundler'
begin
  Bundler.setup
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

$:.unshift(File.join(File.dirname(__FILE__), './lib'))
require 'edtf/version'

require 'rake/clean'

task :default => [:racc, :spec, :cucumber]

desc 'Run an IRB session with CiteProc loaded'
task :console, [:script] do |t,args|
  ARGV.clear

  require 'irb'
  require 'edtf'
  
  IRB.conf[:SCRIPT] = args.script
  IRB.start
end

desc 'Generates the parser'
task :racc do
  system 'bundle exec racc -o lib/edtf/parser.rb lib/edtf/parser.y'
end

desc 'Generates the parser with debug information'
task :racc_debug do
  system 'bundle exec racc -v -t -o lib/edtf/parser.rb lib/edtf/parser.y'
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber)

desc 'Builds the gem file'
task :build => [:racc] do
  system 'gem build edtf.gemspec'
end

task :release => [:build] do
  system "git tag #{EDTF::VERSION}"
  system "gem push edtf-#{EDTF::VERSION}.gem"
end

CLEAN.include('lib/edtf/parser.rb')
CLEAN.include('lib/edtf/parser.output')
CLEAN.include('*.gem')
CLEAN.include('**/*.rbc')
