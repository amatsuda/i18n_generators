require File.join(File.dirname(__FILE__), 'generators/i18n/i18n_generator')
require File.join(File.dirname(__FILE__), 'generators/i18n_locales/i18n_locales_command')
require File.join(File.dirname(__FILE__), 'generators/i18n_models/i18n_models_command')
Rails::Generator::Commands::Create.send :include, I18nGenerator::Generator::Commands::Create

#require File.join(File.dirname(__FILE__), 'generators/i18n/i18n_generator')

