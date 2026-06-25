source 'https://rubygems.org'
gemspec

group :coverage do
  platforms :mri do
    gem 'simplecov'
    gem 'simplecov-lcov'
  end
end

group :debug, optional: true do
  gem 'debug', '>= 1.0.0', require: false
end

group :development do
  gem 'rake'
  gem 'racc'
  gem 'cucumber'
  gem 'rspec'
end
