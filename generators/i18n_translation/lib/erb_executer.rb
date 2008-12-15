require "#{File.dirname(__FILE__)}/through_ryoku"

module I18nTranslationGeneratorModule
  class ErbExecuter
    def exec_erb(filename)
      begin
#         ERB.new(File.read(f)).result
        (m = Module.new).module_eval <<-EOS
          class Executer
            extend ERB::DefMethod
            include ActionView::Helpers::TranslationHelper
            include I18nTranslationGeneratorModule::ThroughRyoku

            nil.class_eval do
              def method_missing(method, *args, &block); nil; end
            end

            def_erb_method 'execute', '#{filename}'
          end
        EOS
        m.const_get('Executer').new.execute { }
        nil.class_eval do
          undef :method_missing
        end
      rescue => e
        p e
        # do nothing
      end
    end
  end
end

