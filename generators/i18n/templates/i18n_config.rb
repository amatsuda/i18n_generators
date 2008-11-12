I18n.load_path += Dir.glob("#{RAILS_ROOT}/lib/locale/*.yml")

I18n.default_locale = '<%= locale_name %>'
I18n.locale         = '<%= locale_name %>'

