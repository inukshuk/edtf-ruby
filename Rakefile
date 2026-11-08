require 'bundler/gem_tasks'

GRAMMARS = %w[lib/edtf/iso lib/edtf/legacy].freeze

desc 'Generate the parsers'
task :racc => GRAMMARS.map { |grammar| "#{grammar}.rb" }

GRAMMARS.each do |grammar|
  file "#{grammar}.rb" => ["#{grammar}.y"] do
    sh "racc -o #{grammar}.rb #{grammar}.y"
  end
end

desc 'Generate the parsers with debug information'
task :racc_debug do
  GRAMMARS.each do |grammar|
    sh "racc -v -t -o #{grammar}.rb #{grammar}.y"
  end
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
