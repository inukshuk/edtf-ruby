source 'https://rubygems.org'
gemspec

group :debug do
  gem 'ruby-debug', :require => false, :platform => :jruby
  gem 'debugger', ['~>1.6', '>=1.6.5'], :require => false, :platform => :mri
  gem 'rubinius-compiler', '~>2.0', :require => false, :platform => :rbx
  gem 'rubinius-debugger', '~>2.0', :require => false, :platform => :rbx
end

group :development do
  gem 'rake'
  gem 'racc'
  gem 'cucumber'
  gem 'rspec'
  gem 'simplecov', '~>0.8', :require => false
  gem 'rubinius-coverage', :platform => :rbx
  gem 'coveralls', :require => false
end

group :extra do
  gem 'ZenTest'
end

# active_support requires this
gem 'i18n'

platform :rbx do
  gem 'rubysl', '~>2.0'
end
