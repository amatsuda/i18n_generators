require 'rubygems'
require 'rails_generator'
require 'rails_generator/commands'
require 'gettext'

class I18nGenerator < Rails::Generator::NamedBase
  attr_reader :locale_name, :cldr, :translator, :generate_translation_only, :generate_locale_only, :include_timestamps

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
    @include_timestamps = true if options[:include_timestamps]
  end

  def manifest
    record do |m|
      m.directory 'config/locales'
      unless options[:generate_translation_only]
        logger.debug 'updating environment.rb ...'
        m.generate_configuration
        if defined_in_rails_i18n_repository?
          logger.debug "fetching #{locale_name}.yml from rails-i18n repository..."
          m.fetch_from_rails_i18n_repository
        else
          logger.debug "generating #{locale_name} YAML files for Rails..."
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
    opt.on('--locale', 'Generate locale files.') {|v| options[:generate_locale_only] = v}
    opt.on('--include-timestamps', 'Include timestamp columns in the YAML translation.') {|v| options[:include_timestamps] = v}
    opt.on('--include-timestamp', 'Include timestamp columns in the YAML translation.') {|v| options[:include_timestamps] = v}
  end

  private
  def defined_in_rails_i18n_repository?
    begin
      uri = "http://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/#{locale_name}.yml"
      OpenURI.open_uri(uri) do |res|
        (res.base_uri.to_s == uri) && (res.status == %w[200 OK])
      end
    rescue
      false
    end
  end
end

require File.join(File.dirname(__FILE__), '../i18n_locale/i18n_locale_command')
require File.join(File.dirname(__FILE__), '../i18n_translation/i18n_translation_command')
Rails::Generator::Commands::Create.send :include, I18nGenerator::Generator::Commands::Create

