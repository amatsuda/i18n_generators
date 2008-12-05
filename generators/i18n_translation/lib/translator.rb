require 'open-uri'

module I18nTranslationGeneratorModule
  class Translator
    def initialize(lang)
      @lang, @cache = lang, {}
    end

    def translate(word)
      return @cache[word] if @cache[word]
      begin
        w = CGI.escape ActiveSupport::Inflector.humanize(word)
        json = OpenURI.open_uri("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=#{w}&langpair=en%7C#{@lang}").read
        result = ActiveSupport::JSON.decode(json)
        result['responseStatus'] == 200 ? (@cache[word] = result['responseData']['translatedText']) : word
      rescue => e
        puts %Q[failed to translate "#{word}" into "#{@lang}" language.]
        word
      end
    end
  end
end

