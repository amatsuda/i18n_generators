Gem::Specification.new do |s|
  s.name     = 'i18n_generator'
  s.version  = '0.0.1'
  s.date     = '2008-11-13 20:00:00'
  s.summary  = 'Generates I18n locale files for Rails 2.2'
  s.email    = 'ronnie@dio.jp'
  s.homepage = 'http://github.com/amatsuda/i18n_generator/'
  s.description = 'A Rails generator plugin & gem that generates Rails 2.2 I18n locale files for almost every known locale.'
  s.has_rdoc = false
  s.authors  = ['Akira Matsuda']
  s.files    = %w[History.txt MIT-LICENSE README Rakefile USAGE generators/i18n/USAGE generators/i18n/commands.rb generators/i18n/i18n_generator.rb generators/i18n/lib/cldr.rb generators/i18n/lib/yaml.rb templates/base.yml templates/i18n_config.rb i18n_generator.rb init.rb rails/init.rb]
end

