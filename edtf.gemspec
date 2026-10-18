require_relative 'lib/edtf/version'

Gem::Specification.new do |s|
  s.name        = 'edtf'
  s.version     = EDTF::VERSION.dup
  s.authors     = ['Sylvester Keil', 'Ilja Srna']
  s.homepage    = 'https://github.com/inukshuk/edtf-ruby'
  s.summary     = 'Extended Date/Time Format for Ruby.'
  s.description = 'A Ruby implementation of the Extended Date/Time Format (EDTF).'
  s.license     = 'BSD-2-Clause-Views'

  s.metadata = {
    'source_code_uri' => 'https://github.com/inukshuk/edtf-ruby',
    'bug_tracker_uri' => 'https://github.com/inukshuk/edtf-ruby/issues',
    'rubygems_mfa_required' => 'true'
  }

  s.required_ruby_version = '>= 3.3'
  s.add_dependency('activesupport', '>= 3.0', '< 9.0')
  s.add_dependency('racc', '~> 1.7')

  s.rdoc_options = %w{
    --line-numbers
    --title EDTF-Ruby
    --main README.md
    --exclude lib/edtf/parser.rb
  }
  s.extra_rdoc_files = %w{README.md LICENSE}

  s.files = Dir['lib/**/*.{rb,y}'] + %w[LICENSE README.md]
end
