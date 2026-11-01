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

# ActiveSupport patches Date and Time globally and cannot be unloaded,
# so its examples run in their own process (see .rspec).
namespace :spec do
  RSpec::Core::RakeTask.new(:active_support) do |t|
    t.pattern = 'spec/active_support/**/*_spec.rb'
    t.rspec_opts = %w[--exclude-pattern '']
  end
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber)

task :default => [:spec, 'spec:active_support', :cucumber]
