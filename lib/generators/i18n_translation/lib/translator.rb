require 'open-uri'

module I27r
  class TranslationError < StandardError; end

  module GoogleTranslate
    def _translate(word, lang)
      w = CGI.escape ActiveSupport::Inflector.humanize(word)
      json = OpenURI.open_uri("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=#{w}&langpair=en%7C#{lang}").read
      result = if RUBY_VERSION >= '1.9'
        require 'json'
        ::JSON.parse json
      else
        ActiveSupport::JSON.decode(json)
      end
      if result['responseStatus'] == 200
        result['responseData']['translatedText']
      else
        raise TranslationError.new result.inspect
      end
    end
  end

  module BabelFish
    def _translate(word, lang)
      require 'mechanize'
      w = CGI.escape ActiveSupport::Inflector.humanize(word)

      agent = Mechanize.new
      url = "http://babelfish.yahoo.com/translate_txt?lp=en_#{lang}&trtext=#{w}"
      page = agent.get(url)
      page.search('#result div').text
    end
  end

  class Translator
    include BabelFish

    def initialize(lang)
      @lang, @cache = lang, {}
    end

    def translate(word)
      return @cache[word] if @cache[word]

      translated = _translate word, @lang
      if translated.blank? || (translated == word)
        word
      else
        @cache[word] = translated
        translated
      end
    rescue => e
      Rails.logger.debug e
      puts %Q[failed to translate "#{word}" into "#{@lang}" language.]
      word
    end
  end
end
