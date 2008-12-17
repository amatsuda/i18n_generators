Gem::Specification.new do |s|
  s.name     = 'i18n_generators'
  s.version  = '0.4.0'
  s.date     = '2008-12-17'
  s.summary  = 'Generates I18n locale files for Rails 2.2'
  s.email    = 'ronnie@dio.jp'
  s.homepage = 'http://github.com/amatsuda/i18n_generators/'
  s.description = 'A Rails generator plugin & gem that generates Rails 2.2 I18n locale files for almost every known locale.'
  s.has_rdoc = false
  s.authors  = ['Akira Matsuda']
  s.files    = %w[
MIT-LICENSE
README.rdoc
Rakefile
generators/i18n/USAGE
generators/i18n/i18n_generator.rb
generators/i18n/lib/yaml.rb
generators/i18n/templates/base.yml
generators/i18n/templates/i18n_config.rb
generators/i18n/templates/translation.yml
generators/i18n_locale/USAGE
generators/i18n_locale/i18n_locale_command.rb
generators/i18n_locale/i18n_locale_generator.rb
generators/i18n_locale/lib/cldr.rb
generators/i18n_scaffold/i18n_scaffold_generator.rb
generators/i18n_scaffold/templates/controller.rb
generators/i18n_scaffold/templates/functional_test.rb
generators/i18n_scaffold/templates/helper.rb
generators/i18n_scaffold/templates/helper_test.rb
generators/i18n_scaffold/templates/layout.html.erb
generators/i18n_scaffold/templates/style.css
generators/i18n_scaffold/templates/view_edit.html.erb
generators/i18n_scaffold/templates/view_index.html.erb
generators/i18n_scaffold/templates/view_new.html.erb
generators/i18n_scaffold/templates/view_show.html.erb
generators/i18n_translation/USAGE
generators/i18n_translation/i18n_translation_command.rb
generators/i18n_translation/i18n_translation_generator.rb
generators/i18n_translation/lib/erb_executer.rb
generators/i18n_translation/lib/recording_backend.rb
generators/i18n_translation/lib/through_ryoku.rb
generators/i18n_translation/lib/translator.rb
spec/cldr_spec.rb
spec/data/cldr/ja.html
spec/data/yml/active_record/en-US.yml
spec/i18n_locale_command_spec.rb
spec/i18n_translation_command_spec.rb
spec/translator_spec.rb
spec/yaml_spec.rb]
  s.rubygems_version = '1.3.1'
  s.add_dependency 'gettext'
end

