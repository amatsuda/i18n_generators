$KCODE = 'U'

require 'open-uri'

module I18nLocalesGeneratorModule
  class CldrDocument
    def initialize(locale_name)
      @locale_name = locale_name
      @summaries = [load_cldr_data(locale_name.tr('-', '_')), load_cldr_data(locale_name.sub(/-.*/, ''))]
    end

    def lookup(path)
      case path.sub(/^\/#{@locale_name}\//, '')
      when 'date/formats/default'
        convert_date_pattern search('calendar-gregorian', 'pattern', 'date-medium')
      when 'date/formats/short'
        convert_date_pattern search('calendar-gregorian', 'pattern', 'date-short')
      when 'date/formats/long'
        convert_date_pattern search('calendar-gregorian', 'pattern', 'date-full')
      when 'date/day_names'
        [search('calendar-gregorian', 'day', 'sunday:format-wide'),
        search('calendar-gregorian', 'day', 'monday:format-wide'),
        search('calendar-gregorian', 'day', 'tuesday:format-wide'),
        search('calendar-gregorian', 'day', 'wednesday:format-wide'),
        search('calendar-gregorian', 'day', 'thursday:format-wide'),
        search('calendar-gregorian', 'day', 'friday:format-wide'),
        search('calendar-gregorian', 'day', 'saturday:format-wide')]
      when 'date/abbr_day_names'
        [search('calendar-gregorian', 'day', 'sunday:format-abbreviated'),
        search('calendar-gregorian', 'day', 'monday:format-abbreviated'),
        search('calendar-gregorian', 'day', 'tuesday:format-abbreviated'),
        search('calendar-gregorian', 'day', 'wednesday:format-abbreviated'),
        search('calendar-gregorian', 'day', 'thursday:format-abbreviated'),
        search('calendar-gregorian', 'day', 'friday:format-abbreviated'),
        search('calendar-gregorian', 'day', 'saturday:format-abbreviated')]
      when 'date/month_names'
        ['~',
        search('calendar-gregorian', 'month', '[01]-format-wide'),
        search('calendar-gregorian', 'month', '[02]-format-wide'),
        search('calendar-gregorian', 'month', '[03]-format-wide'),
        search('calendar-gregorian', 'month', '[04]-format-wide'),
        search('calendar-gregorian', 'month', '[05]-format-wide'),
        search('calendar-gregorian', 'month', '[06]-format-wide'),
        search('calendar-gregorian', 'month', '[07]-format-wide'),
        search('calendar-gregorian', 'month', '[08]-format-wide'),
        search('calendar-gregorian', 'month', '[09]-format-wide'),
        search('calendar-gregorian', 'month', '[10]-format-wide'),
        search('calendar-gregorian', 'month', '[11]-format-wide'),
        search('calendar-gregorian', 'month', '[12]-format-wide')]
      when 'date/abbr_month_names'
        ['~',
        search('calendar-gregorian', 'month', '[01]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[02]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[03]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[04]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[05]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[06]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[07]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[08]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[09]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[10]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[11]-format-abbreviated'),
        search('calendar-gregorian', 'month', '[12]-format-abbreviated')]
      # when 'date/order'
      when 'time/formats/default'
        format = search('calendar-gregorian', 'pattern', 'date+time')
        date = convert_date_pattern search('calendar-gregorian', 'pattern', 'date-medium')
        time = convert_date_pattern search('calendar-gregorian', 'pattern', 'time-medium')
        (format.nil? || date.nil? || time.nil?) ? nil : format.sub('{0}', time).sub('{1}', date)
      when 'time/formats/short'
        format = search('calendar-gregorian', 'pattern', 'date+time')
        date = convert_date_pattern search('calendar-gregorian', 'pattern', 'date-short')
        time = convert_date_pattern search('calendar-gregorian', 'pattern', 'time-short')
        (format.nil? || date.nil? || time.nil?) ? nil : format.sub('{0}', time).sub('{1}', date)
      when 'time/formats/long'
        format = search('calendar-gregorian', 'pattern', 'date+time')
        date = convert_date_pattern search('calendar-gregorian', 'pattern', 'date-full')
        time = convert_date_pattern search('calendar-gregorian', 'pattern', 'time-full')
        (format.nil? || date.nil? || time.nil?) ? nil : format.sub('{0}', time).sub('{1}', date)
      when 'time/am'
        search('calendar-gregorian', 'day-period', 'am')
      when 'time/pm'
        search('calendar-gregorian', 'day-period', 'pm')
      # action_view
      when 'number/format/separator'
        search('number', 'symbol', 'decimal')
      when 'number/format/separator'
        search('number', 'symbol', 'group')
      when 'number/currency/format/format'
        format = search('number', 'currency', 'name-pattern/​other')
        format.nil? ? nil : format.tr(' ', '').sub('{0}', '%u').sub('{1}', '%n')
      else
        nil
      end
    end 

    private
    def load_cldr_data(locale_name)
      cldr = begin
        OpenURI.open_uri("http://www.unicode.org/cldr/data/charts/summary/#{locale_name}.html").read
      rescue
        puts "WARNING: Couldn't find locale data for #{locale_name} on the web."
        ''
      end
      cldr.split("\n").grep(/^<tr>/).delete_if {|r| r =~ /^<tr><td>\d*<\/td><td class='[gn]'>names<\/td>/}
    end

    def search(n1, n2, g)
      pattern = Regexp.new /<tr><td>\d*<\/td><td class='[ng]'>#{Regexp.quote(n1)}<\/td><td class='[ng]'>#{Regexp.quote(n2)}<\/td><td class='[ng]'>#{Regexp.quote(g)}<\/td>/
      extract_pattern = /<td class='v'>(?:<span.*?>)?(.*?)(?:<\/span>)?<\/td><td>/
      _, value = *extract_pattern.match(@summaries[0].grep(pattern).first)
      return value unless value.nil?
      _, value = *extract_pattern.match(@summaries[1].grep(pattern).first)
      value
    end

    def convert_date_pattern(val)
      return val if val.nil?
      val = val.sub('MMMM', '%B').sub('MMM', '%b')
      val = val.sub('yyyy', '%Y').sub('yy', '%y').sub('MM', '%m').sub('M', '%m').sub(/dd|d/, '%d')
      val.sub('EEEEE', '%a').sub('EEEE', '%A').sub('H', '%H').sub('mm', '%M').sub('ss', '%S').sub('v', '%Z')
    end
  end
end

