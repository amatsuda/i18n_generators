require 'rubygems'
require 'rails_generator'
require 'rails_generator/commands'
require 'gettext'

class I18nGenerator < Rails::Generator::NamedBase
  attr_reader :locale_name, :cldr, :translator, :generate_translation_only, :generate_locale_only

  def initialize(runtime_args, runtime_options = {})
    if options[:scaffold]
      #TODO invoke scaffold generator
      puts 'please use generate i18n_scaffold command'
      exit
    end

    super
    unless name =~ /^[a-zA-Z]{2}([-_][a-zA-Z]{2})?$/
      puts 'ERROR: Wrong locale format. Please input in ?? or ??-?? format.'
      exit
    end
    @locale_name = name.length == 5 ? "#{name[0..1].downcase}-#{name[3..4].upcase}" : "#{name[0..1].downcase}"
    GetText.bindtextdomain 'rails'
    GetText.locale = @locale_name

    unless options[:generate_translation_only]
      @cldr = CldrDocument.new @locale_name
    end
    unless options[:generate_locale_only]
      lang = @locale_name.sub(/-.*$/, '')
      @translator = Translator.new lang
    end
  end

  def manifest
    record do |m|
      m.directory 'config/locales'
      unless options[:generate_translation_only]
        m.generate_configuration
        if defined_in_rails_i18n_repository?
          m.fetch_from_rails_i18n_repository
        else
          m.active_support_yaml
          m.active_record_yaml
          m.action_view_yaml
        end
      end
      unless options[:generate_locale_only]
        m.translation_yaml
      end
    end
  end

  protected
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on('--translation',
           'Generate translations for all models with their attributes and all translation keys in the view files.') {|v| options[:generate_translation_only] = v}
    opt.on('--locale',
           'Generate locale files.') {|v| options[:generate_locale_only] = v}
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

require File.join(File.dirname(__FILE__), '../i18n_locale/i18n_locale_command')
require File.join(File.dirname(__FILE__), '../i18n_translation/i18n_translation_command')
Rails::Generator::Commands::Create.send :include, I18nGenerator::Generator::Commands::Create

