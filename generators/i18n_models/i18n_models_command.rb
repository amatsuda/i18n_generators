require 'rails_generator'
require 'rails_generator/commands'
require File.join(File.dirname(__FILE__), 'lib/translator')
include I18nModelsGeneratorModule

module I18nGenerator::Generator
  module Commands #:nodoc:
    module Create
      def models_yaml
        I18n.locale = locale_name
        models = model_filenames.map do |model_name|
          model = begin
            m = model_name.camelize.constantize
            next unless m.respond_to?(:content_columns)
            m
          rescue
            next
          end
          registered_t_name = I18n.t("activerecord.models.#{model_name}", :default => model_name)

          model.class_eval <<-END
  def self.english_name
    "#{model_name}"
  end

  def self.translated_name
    "#{registered_t_name != model_name ? registered_t_name : self.translator.translate(model_name)}"
  end
END
          model.content_columns.each do |col|
            next if %w[created_at updated_at].include? col.name
            registered_t_name = I18n.t("activerecord.attributes.#{model_name}.#{col.name}", :default => col.name)
            col.class_eval <<-END
  def translated_name
    "#{registered_t_name != col.name ? registered_t_name : self.translator.translate(col.name)}"
  end
END
          end
          model
        end.compact
        generate_yaml(locale_name, models)
      end

      private
      def model_filenames
        Dir.chdir("#{RAILS_ROOT}/app/models/") do
          Dir["**/*.rb"].map {|m| m.sub(/\.rb$/, '')}
        end
      end

      def generate_yaml(locale_name, models)
        template 'i18n:models.yml', "config/locales/models_#{locale_name}.yml", :assigns => {:locale_name => locale_name, :models => models}
      end
    end
  end
end

