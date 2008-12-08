require 'rails_generator'
require 'rails_generator/commands'
require File.join(File.dirname(__FILE__), 'lib/translator')
require File.join(File.dirname(__FILE__), 'lib/recording_backend')
require File.join(File.dirname(__FILE__), 'lib/erb_executer')
include I18nTranslationGeneratorModule

module I18nGenerator::Generator
  module Commands #:nodoc:
    module Create
      def translation_yaml
        I18n.locale = locale_name
        threads = []
        now = Time.now
        models = model_filenames.map do |model_name|
          model = begin
            m = model_name.camelize.constantize
            next unless m.respond_to?(:content_columns)
            m
          rescue
            next
          end
          threads << Thread.new do
            Thread.pass
            registered_t_name = I18n.t("activerecord.models.#{model_name}", :default => model_name, :locale => locale_name)

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
              registered_t_name = I18n.t("activerecord.attributes.#{model_name}.#{col.name}", :default => col.name, :locale => locale_name)
              col.class_eval <<-END
    def translated_name
      "#{registered_t_name != col.name ? registered_t_name : self.translator.translate(col.name)}"
    end
  END
            end
          end
          model
        end.compact
        threads.each {|t| t.join}
        logger.debug "took #{Time.now - now} secs to translate #{models.count} models."
        # pick all translated keywords from view files
        I18n.backend = RecordingBackend.new

        Dir["#{RAILS_ROOT}/app/views/**/*.erb"].each do |f|
          ErbExecuter.new.exec_erb f
        end
        keys_in_view = I18n.backend.keys
        keys_in_view -= models.map {|m| m.english_name.to_sym}
        keys_in_view -= models.inject([]) {|a, m| a + m.content_columns.map {|c| "#{m.english_name}.#{c.name}".to_sym}}
        now = Time.now
        translated_hash = translate_all keys_in_view
        logger.debug "took #{Time.now - now} secs to translate #{keys_in_view.count} words."
        generate_yaml(locale_name, models, translated_hash)
      end

      private
      def model_filenames
        Dir.chdir("#{RAILS_ROOT}/app/models/") do
          Dir["**/*.rb"].map {|m| m.sub(/\.rb$/, '')}
        end
      end

      def generate_yaml(locale_name, models, translations)
        template 'i18n:translation.yml', "config/locales/translation_#{locale_name}.yml", :assigns => {:locale_name => locale_name, :models => models, :translations => translations}
      end

      # receives an array of keys and returns :key => :translation hash
      def translate_all(keys)
        threads = []
        ret = keys.inject({}) do |hash, key|
          threads << Thread.new do
            Thread.pass
            hash[key] = translator.translate key
          end
          hash
        end
        threads.each {|t| t.join}
        ret
      end
    end
  end
end

