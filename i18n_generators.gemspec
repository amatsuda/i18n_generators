# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'i18n_generators/version'

Gem::Specification.new do |s|
  s.name        = 'i18n_generators'
  s.version     = I18nGenerators::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Akira Matsuda']
  s.email       = ['ronnie@dio.jp']
  s.homepage    = 'https://github.com/amatsuda/i18n_generators'
  s.summary     = 'Generates I18n locale files for Rails 3 and Rails 2'
  s.description = 'A Rails generator plugin & gem that generates Rails I18n locale files for almost every known locale.'

  s.rubyforge_project = 'i18n_generators'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.extra_rdoc_files = ['README.rdoc']
  s.licenses = ['MIT']
end
