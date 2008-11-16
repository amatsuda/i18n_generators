require 'rails_generator'
require 'rails_generator/commands'
require 'rubygems'
require 'gettext'

class I18nGenerator < Rails::Generator::NamedBase
  attr_reader :locale_name, :cldr, :translator, :generate_models_only, :generate_locales_only

  def initialize(runtime_args, runtime_options = {})
    super
    unless name =~ /[a-zA-Z]{2}[-_][a-zA-Z]{2}/
      puts 'ERROR: Wrong locale format. Please input in ??-?? format.'
      exit
    end
    @locale_name = "#{name[0..1].downcase}-#{name[3..4].upcase}"
    GetText.bindtextdomain 'rails'
    GetText.locale = @locale_name

    unless self.generate_models_only
      @cldr = CldrDocument.new @locale_name
    end
    unless self.generate_locales_only
      lang = @locale_name.sub(/-.*$/, '')
      @translator = Translator.new lang
    end
  end

  def manifest
    record do |m|
      m.directory 'lib/locale'
      unless self.generate_models_only
        m.template 'i18n:i18n_config.rb', 'config/initializers/i18n_config.rb', :assigns => {:locale_name => @locale_name}
        m.active_support_yaml
        m.active_record_yaml
        m.action_view_yaml
      end
      unless self.generate_locales_only
        m.models_yaml
      end
    end
  end
end

require File.join(File.dirname(__FILE__), '../i18n_locales/i18n_locales_command')
require File.join(File.dirname(__FILE__), '../i18n_models/i18n_models_command')
Rails::Generator::Commands::Create.send :include, I18nGenerator::Generator::Commands::Create

