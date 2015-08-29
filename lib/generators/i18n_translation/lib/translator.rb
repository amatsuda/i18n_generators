# -*- coding: utf-8 -*-
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

  module GoogleTranslate2
    def _translate(word, lang)
      w = CGI.escape ActiveSupport::Inflector.humanize(word)
      json = OpenURI.open_uri("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=#{w}&langpair=en%7C#{lang}").read
      json = OpenURI.open_uri("https://translate.google.com/translate_a/single?client=t&sl=en&tl=#{lang}&hl=zh-CN&dt=bd&dt=ex&dt=ld&dt=md&dt=qc&dt=rw&dt=rm&dt=ss&dt=t&dt=at&dt=sw&ie=UTF-8&oe=UTF-8&otf=1&ssel=0&tsel=0&q=#{w}",
                              "accept-language" => "en-US,en;q=0.8",
                              "user-agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36",
                              "accept" => "*/*'",
                              "referer" => "https://translate.google.com/"
                              ).read
      index = json.index("],[")
      json = a = json[2..index]
      result = if RUBY_VERSION >= '1.9'
        require 'json'
        ::JSON.parse json
      else
        ActiveSupport::JSON.decode(json)
      end
      if result.length == 2
        result[0]
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

  module BingTranslator
    def _translate(word, lang)
      require 'cgi'

      w = CGI.escape ActiveSupport::Inflector.humanize(word)
      json = OpenURI.open_uri("http://api.microsofttranslator.com/v2/ajax.svc/TranslateArray?appId=%22T5y_QKkSEGi7P462fd0EwjEhB0_XGUl8PNTgQylxBYks*%22&texts=[%22#{w}%22]&from=%22en%22&to=%22#{lang}%22").read.gsub(/\A([^\[]+)/, '')

      result = if RUBY_VERSION >= '1.9'
        require 'json'
        ::JSON.parse json
      else
        ActiveSupport::JSON.decode(json)
      end

      if result.any?
        result[0]['TranslatedText']
      else
        raise TranslationError.new result.inspect
      end
    end
  end

  class Translator
    #include BingTranslator
    include GoogleTranslate2
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
