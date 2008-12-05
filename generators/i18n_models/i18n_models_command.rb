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
        # pick all translated keywords from view files
        def I18n.translate(key, options = {})
          Thread.current[:translation_keys] << key.to_sym
        end
        #TODO alias?
        def I18n.t(key, options = {})
          p key
          Thread.current[:translation_keys] << key.to_sym
        end
        Object.class_eval do
          define_method(:translate) do |*args|
            'Thread.current[:translation_keys] << args[0].to_sym'
          end
          define_method(:t) do |*args|
            'Thread.current[:translation_keys] << args[0].to_sym'
          end
          define_method(:method_missing) do |*args|
            nil
          end
        end
        def nil.method_missing(method, *args, &block)
          nil
        end

        Thread.current[:translation_keys] = []
        Dir["#{RAILS_ROOT}/app/views/**/*.erb"].each do |f|
          begin
#             ERB.new(File.read(f)).result
            exec_erb f
          rescue
            # do nothing
          end
        end
        keys_in_view = Thread.current[:translation_keys].uniq!
        keys_in_view -= models.map {|m| m.english_name.to_sym}
        keys_in_view -= models.inject([]) {|a, m| a + m.content_columns.map {|c| "#{m.english_name}.#{c.name}".to_sym}}
        generate_yaml(locale_name, models, keys_in_view.inject({}) {|h, k| h[k] = translator.translate(k); h})
      end

      private
      def model_filenames
        Dir.chdir("#{RAILS_ROOT}/app/models/") do
          Dir["**/*.rb"].map {|m| m.sub(/\.rb$/, '')}
        end
      end

      def exec_erb(filename)
        (m = Module.new).module_eval <<-EOS
          class ERBExecuter
            extend ERB::DefMethod
            def_erb_method 'execute', '#{filename}'
        end
        EOS
        executer = m.const_get 'ERBExecuter'
        executer.new.execute { }
      end

      def generate_yaml(locale_name, models, translations)
        template 'i18n:models.yml', "config/locales/models_#{locale_name}.yml", :assigns => {:locale_name => locale_name, :models => models, :translations => translations}
      end
    end
  end
end

