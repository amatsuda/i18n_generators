require File.join(File.dirname(__FILE__), '../i18n/i18n_generator')

class I18nTranslationGenerator < I18nGenerator
  def initialize(runtime_args, runtime_options = {})
    super
    options[:generate_translation_only] = true
  end
end

