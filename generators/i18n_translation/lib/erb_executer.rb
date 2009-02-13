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

            fname = '#{filename}'
            erb = nil
            File.open(fname) {|f| erb = ERB.new(f.read, nil, '-') }
            erb.def_method(self, 'execute', fname)
          end
        EOS
        nil.class_eval {def method_missing(method, *args, &block); nil; end}
        m.const_get('Executer').new.execute { }
      rescue => e
        p e
        # do nothing
      ensure
        nil.class_eval {undef :method_missing} if nil.respond_to? :method_missing
      end
    end
  end
end

