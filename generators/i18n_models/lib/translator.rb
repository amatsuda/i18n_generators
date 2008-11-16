require 'open-uri'

module I18nModelsGeneratorModule
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
        return @cache[word] = result['responseData']['translatedText'] if result['responseStatus'] == 200
      rescue => e
        p e
        puts %Q[failed to translate "#{word}" into "#{@lang}" language.]
        word
      end
    end
  end
end

