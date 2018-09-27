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
  s.summary     = 'A Rails generator that generates Rails I18n locale files with automatic translation for almost every known locale.'
  s.description = 'A Rails generator that generates Rails I18n locale files with automatic translation for almost every known locale.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.licenses = ['MIT']

  s.add_runtime_dependency 'railties', '>= 3.0.0'
  s.add_runtime_dependency 'activerecord', '>= 3.0.0'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'test-unit-rr'
  s.add_development_dependency 'rake'
end
