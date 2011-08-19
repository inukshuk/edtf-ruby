source :rubygems
gemspec

group :debug do
	gem 'ruby-debug19', :require => 'ruby-debug', :platforms => [:mri_19]
	gem 'ruby-debug', :platforms => [:mri_18, :jruby]
	gem 'rbx-trepanning', :platforms => [:rbx]
end

# active_support requires this
gem 'i18n'