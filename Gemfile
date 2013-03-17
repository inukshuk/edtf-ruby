source 'https://rubygems.org'
gemspec

group :debug do
	gem 'debugger', :platforms => [:mri_19, :mri_20]
	gem 'ruby-debug', :platforms => [:mri_18, :jruby]
	gem 'rbx-trepanning', :platforms => [:rbx]
end

group :development do
  gem 'rake'
  gem 'racc'
  gem 'cucumber'
  gem 'rspec'
  gem 'ZenTest'
end

# active_support requires this
gem 'i18n'