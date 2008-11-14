require 'open-uri'

module I18nModelsGeneratorModule
  class Translator
    #TODO
    def self.translatable?(lang)
    end

    def self.translate(word, lang)
      begin
        json = OpenURI.open_uri("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=#{word}&langpair=en%7C#{lang}").read
        result = ActiveSupport::JSON.decode(json)
        return result['responseData']['translatedText'] if result['responseStatus'] == 200
      rescue e
        puts %Q[failed to translate "#{word}" into "#{lang}" language.]
        word
      end
    end
  end
end

