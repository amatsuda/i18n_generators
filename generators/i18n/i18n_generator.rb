require 'rubygems'
require 'rails_generator'
require 'gettext'

class I18nGenerator < Rails::Generator::NamedBase
  attr_reader :locale_name, :cldr

  def initialize(runtime_args, runtime_options = {})
    super
    unless name =~ /[a-zA-Z]{2}[-_][a-zA-Z]{2}/
      puts 'ERROR: Wrong locale format. Please input in ??-?? format.'
      exit
    end
    @locale_name = "#{name[0..1].downcase}-#{name[3..4].upcase}"
    GetText.bindtextdomain 'rails'
    GetText.locale = @locale_name

    @cldr = CldrDocument.new @locale_name
  end

  def manifest
    record do |m|
      m.directory 'lib/locale'
      m.template 'i18n_config.rb', 'config/initializers/i18n_config.rb', :assigns => {:locale_name => @locale_name}
      m.active_support_yaml
      m.active_record_yaml
      m.action_view_yaml

      m.models_yaml
    end
  end
end

