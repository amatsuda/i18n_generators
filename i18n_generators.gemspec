Gem::Specification.new do |s|
  s.name     = 'i18n_generators'
  s.version  = '0.0.5'
  s.date     = '2008-11-15'
  s.summary  = 'Generates I18n locale files for Rails 2.2'
  s.email    = 'ronnie@dio.jp'
  s.homepage = 'http://github.com/amatsuda/i18n_generators/'
  s.description = 'A Rails generator plugin & gem that generates Rails 2.2 I18n locale files for almost every known locale.'
  s.has_rdoc = false
  s.authors  = ['Akira Matsuda']
  s.files    = %w[
MIT-LICENSE
README
Rakefile
generators/i18n/USAGE
generators/i18n/i18n_generator.rb
generators/i18n_locales/USAGE
generators/i18n_locales/i18n_locales_command.rb
generators/i18n_locales/i18n_locales_generator.rb
generators/i18n_locales/lib/cldr.rb
generators/i18n_locales/lib/yaml.rb
generators/i18n_models/USAGE
generators/i18n_models/i18n_models_command.rb
generators/i18n_models/i18n_models_generator.rb
generators/i18n_models/lib/translator.rb
generators/i18n/templates/base.yml
generators/i18n/templates/i18n_config.rb
generators/i18n/templates/models.yml
spec/cldr_spec.rb
spec/data/cldr/ja.html
spec/data/yml/active_record/en-US.yml
spec/yaml_spec.rb]
  s.rubygems_version = '1.3.1'
  s.add_dependency 'gettext'
end

