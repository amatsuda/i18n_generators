require File.join(File.dirname(__FILE__), '../i18n/i18n_generator')

class I18nLocalesGenerator < I18nGenerator
  def initialize(runtime_args, runtime_options = {})
    @generate_locales_only = true
    super
  end
end

