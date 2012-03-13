require 'generators/i18n_translation/i18n_translation_generator'
require 'generators/i18n_locale/i18n_locale_generator'

class I18nGenerator < Rails::Generators::NamedBase
  def initialize(args, *options)
    super
    @_args, @_options = args, options
  end

  def main
    locale_gen = I18nLocaleGenerator.new(@_args, @_options)
    locale_gen.main

    translation_gen = I18nTranslationGenerator.new(@_args, @_options)
    translation_gen.main
  end
end
