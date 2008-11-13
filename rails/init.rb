require File.join(File.dirname(__FILE__), '../generators/i18n/commands')

Rails::Generator::Commands::Create.send :include, I18nGenerator::Generator::Commands::Create

