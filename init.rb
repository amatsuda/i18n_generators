require 'commands' 
Rails::Generator::Commands::Create.send :include, I18n::Generator::Commands::Create

