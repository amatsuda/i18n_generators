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
        models = model_filenames.map do |model_name|
          model = begin
            m = model_name.camelize.constantize
            next unless m.respond_to?(:content_columns)
            m.class_eval %Q[def self.english_name; "#{model_name}"; end]
            m
          rescue
            next
          end
        end.compact
        translation_keys = []
        translation_keys += models.map {|m| "activerecord.models.#{m.english_name}"}
        models.each do |model|
          translation_keys += model.content_columns.map {|c| "activerecord.attributes.#{model.english_name}.#{c.name}"}
        end

        # pick all translated keywords from view files
        original_backend = I18n.backend
        I18n.backend = RecordingBackend.new

        Dir["#{RAILS_ROOT}/app/views/**/*.erb"].each do |f|
          ErbExecuter.new.exec_erb f
        end
        (translation_keys += I18n.backend.keys).uniq!
        I18n.backend = original_backend

        # translate all keys and generate the YAML file
        now = Time.now
        translations = translate_all(translation_keys)
        logger.debug "took #{Time.now - now} secs to translate."
        generate_yaml(locale_name, translations)
      end

      private
      def model_filenames
        Dir.chdir("#{RAILS_ROOT}/app/models/") do
          Dir["**/*.rb"].map {|m| m.sub(/\.rb$/, '')}
        end
      end

      def generate_yaml(locale_name, translations)
        template 'i18n:translation.yml', "config/locales/translation_#{locale_name}.yml", :assigns => {:locale_name => locale_name, :translations => translations}
      end

      # receives an array of keys and returns :key => :translation hash
      def translate_all(keys)
        returning ActiveSupport::OrderedHash.new do |oh|
          # fix the order first(for multi thread translating)
          keys.each do |key|
            if key.to_s.include? '.'
              key_prefix, key_suffix = key.to_s.split('.')[0...-1], key.to_s.split('.')[-1]
              key_prefix.inject(oh) {|h, k| h[k] ||= ActiveSupport::OrderedHash.new}[key_suffix] = nil
            else
              oh[key] = nil
            end
          end
          threads = []
          keys.each do |key|
            threads << Thread.new do
              logger.debug "translating #{key} ..."
              Thread.pass
              if key.to_s.include? '.'
                key_prefix, key_suffix = key.to_s.split('.')[0...-1], key.to_s.split('.')[-1]
                existing_translation = I18n.t(key, :default => key_suffix, :locale => locale_name)
                key_prefix.inject(oh) {|h, k| h[k]}[key_suffix] = existing_translation != key_suffix ? existing_translation : translator.translate(key_suffix)
              else
                existing_translation = I18n.t(key, :default => key, :locale => locale_name)
                oh[key] = existing_translation != key ? existing_translation : translator.translate(key)
              end
            end
          end
          threads.each {|t| t.join}
        end
      end

      def yamlize(hash, nest_level)
        returning '' do |s|
          hash.each do |k, v|
            if v.is_a?(ActiveSupport::OrderedHash)
              s << "#{'  ' * nest_level}#{k}:\n"
              s << yamlize(v, nest_level + 1)
            else
              s << "#{'  ' * nest_level}#{k}: #{v}\n"
            end
          end
        end
      end
    end
  end
end

