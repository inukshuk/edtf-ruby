# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'edtf/version'

Gem::Specification.new do |s|
  s.name        = 'edtf'
  s.version     = EDTF::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Sylvester Keil']
  s.email       = ['http://sylvester.keil.or.at']
  s.homepage    = 'http://github.com/inukshuk/edtf-ruby'
  s.summary     = 'Extended Date/Time Format for Ruby.'
  s.description = 'A Ruby implementation of the Extended Date/Time Format (EDTF).'
  s.license     = 'FreeBSD'

  s.add_runtime_dependency('activesupport', '>= 3.0', '< 5.0')

  s.files        = `git ls-files`.split("\n") << 'lib/edtf/parser.rb'
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables  = []
  s.require_path = 'lib'

  s.rdoc_options      = %w{--line-numbers --inline-source --title "EDTF-Ruby" --main README.md --webcvs=http://github.com/inukshuk/edtf-ruby/tree/master/}
  s.extra_rdoc_files  = %w{README.md LICENSE}

end

# vim: syntax=ruby
