require 'rubygems'
require 'rails_generator'
require 'rails_generator/commands'
require 'gettext'

class I18nGenerator < Rails::Generator::NamedBase
  attr_reader :locale_name, :cldr, :translator, :generate_models_only, :generate_locales_only

  def initialize(runtime_args, runtime_options = {})
    super
    unless name =~ /^[a-zA-Z]{2}([-_][a-zA-Z]{2})?$/
      puts 'ERROR: Wrong locale format. Please input in ?? or ??-?? format.'
      exit
    end
    @locale_name = name.length == 5 ? "#{name[0..1].downcase}-#{name[3..4].upcase}" : "#{name[0..1].downcase}"
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
      m.directory 'config/locales'
      unless self.generate_models_only
        m.generate_configuration
        if defined_in_rails_i18n_repository?
          m.fetch_from_rails_i18n_repository
        else
          m.active_support_yaml
          m.active_record_yaml
          m.action_view_yaml
        end
      end
      unless self.generate_locales_only
        m.models_yaml
      end
    end
  end

  private
  def defined_in_rails_i18n_repository?
    begin
      OpenURI.open_uri("http://github.com/svenfuchs/rails-i18n/tree/master/rails/locale/#{locale_name}.yml").status == %w[200 OK]
    rescue
      false
    end
  end
end

require File.join(File.dirname(__FILE__), '../i18n_locales/i18n_locales_command')
require File.join(File.dirname(__FILE__), '../i18n_models/i18n_models_command')
Rails::Generator::Commands::Create.send :include, I18nGenerator::Generator::Commands::Create

