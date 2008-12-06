module I18nTranslationGeneratorModule
  class RecordingBackend
    attr_reader :keys

    def initialize
      @keys = []
    end

    def translate(locale, key, options = {})
      p key.to_sym
      @keys << key.to_sym
    end
    alias :t :translate
  end
end

