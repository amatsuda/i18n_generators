require 'net/https'

class I18nLocaleGenerator < Rails::Generators::NamedBase
  def main
    unless file_name =~ /^[a-zA-Z]{2}([-_][a-zA-Z]+)?$/
      log 'ERROR: Wrong locale format. Please input in ?? or ??-?? format.'
      exit
    end
    generate_configuration
    fetch_from_rails_i18n_repository
  end

  private
  def generate_configuration
    return if I18n.default_locale.to_s == locale_name
    log 'updating application.rb...'
#     environment "config.i18n.default_locale = :#{locale_name}"
    config = add_locale_config File.read(File.join(Rails.root, 'config/application.rb'))
    create_file 'config/application.rb', config
  end

  def add_locale_config(config_contents)
    new_line = "    config.i18n.default_locale = #{locale_name.to_sym.inspect.tr('"', '\'')}"
    if config_contents =~ /\n *config\.i18n\.default_locale *=/
      config_contents.sub(/ *config\.i18n\.default_locale *=.*/, new_line)
    elsif config_contents =~ /\n *#? *config\.i18n\.default_locale *=/
      config_contents.sub(/ *#? *config\.i18n\.default_locale *=.*/, new_line)
    elsif sentinel = config_contents.scan(/class [a-z_:]+ < Rails::Application/i).first
      config_contents.sub sentinel, "#{sentinel}\n#{new_line}"
    else
      config_contents
    end
  end

  def fetch_from_rails_i18n_repository
    log "fetching #{locale_name}.yml from rails-i18n repository..."
    begin
      get "https://github.com/svenfuchs/rails-i18n/raw/master/rails/locale/#{locale_name}.yml", "config/locales/#{locale_name}.yml"
      I18n.load_path.unshift "config/locales/#{locale_name}.yml"
    rescue
      log "could not find #{locale_name}.yml on rails-i18n repository"
    end
  end

  def locale_name
    @_locale_name ||= file_name.tr('_', '-').split('-').each.with_index.map {|s, i| i == 0 ? s : s.upcase}.join('-')
  end
end
