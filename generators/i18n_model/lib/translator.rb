require 'open-uri'

module I18nModelGenerator
  class Translator
    #TODO
    def self.translatable?(lang)
    end

    def self.translate(word, lang)
      json = OpenURI.open_uri("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=#{word}&langpair=en%7C#{lang}").read
      result = ActiveSupport::JSON.decode(json)
      result['responseData']['translatedText']
    end
  end
end

