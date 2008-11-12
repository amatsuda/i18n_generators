require 'rubygems'
require 'gettext'

class I18nGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      unless name =~ /[a-zA-Z]{2}[-_][a-zA-Z]{2}/
        puts 'ERROR: Wrong locale format. Please input in ??-?? format.'
        exit
      end
      m.directory 'lib/locale'
      m.execute "#{name[0..1].downcase}-#{name[3..4].upcase}"
    end
  end
end

