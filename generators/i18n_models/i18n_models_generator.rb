require File.join(File.dirname(__FILE__), '../../i18n_generator')

class I18nModelsGenerator < I18nGenerator
  def initialize(runtime_args, runtime_options = {})
    super
    @generate_models_only = true
  end
end

