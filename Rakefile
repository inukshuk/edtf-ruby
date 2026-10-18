require 'bundler/gem_tasks'

desc 'Generate the parser'
task :racc => ['lib/edtf/parser.rb']

file 'lib/edtf/parser.rb' => ['lib/edtf/parser.y'] do
  sh 'racc -o lib/edtf/parser.rb lib/edtf/parser.y'
end

desc 'Generate the parser with debug information'
task :racc_debug do
  sh 'racc -v -t -o lib/edtf/parser.rb lib/edtf/parser.y'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber)

task :default => [:spec, :cucumber]
