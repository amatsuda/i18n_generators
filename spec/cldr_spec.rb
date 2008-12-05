$KCODE = 'U'

require File.join(File.dirname(__FILE__), '../generators/i18n_locale/lib/cldr')
include I18nLocaleGeneratorModule

describe CldrDocument do
  before do
    OpenURI.stub!(:open_uri).and_return(File.open(File.join(File.dirname(__FILE__), 'data/cldr/ja.html')))
    @cldr = CldrDocument.new 'ja-JP'
  end

  it 'fetches date/formats/default value' do
    @cldr.lookup('date/formats/default').should == '%Y/%m/%d'
  end

  it 'fetches date/formats/short value' do
    @cldr.lookup('date/formats/short').should == '%y/%m/%d'
  end

  it 'fetches date/formats/long value' do
    @cldr.lookup('date/formats/long').should == '%Y年%m月%d日%A'
  end

  it 'fetches date/day_names value' do
    @cldr.lookup('date/day_names').should == ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日']
  end

  it 'fetches date/abbr_day_names value' do
    @cldr.lookup('date/abbr_day_names').should == ['日', '月', '火', '水', '木', '金', '土']
  end

  it 'fetches time/formats/default value' do
    @cldr.lookup('time/formats/default').should == '%Y/%m/%d %H:%M:%S'
  end

  it 'fetches time/formats/short value' do
    @cldr.lookup('time/formats/short').should == '%y/%m/%d %H:%M'
  end

  it 'fetches time/formats/long value' do
    @cldr.lookup('time/formats/long').should == '%Y年%m月%d日%A %H時%M分%S秒%Z'
  end

  it 'fetches time/am value' do
    @cldr.lookup('time/am').should == '午前'
  end

  it 'fetches time/pm value' do
    @cldr.lookup('time/pm').should == '午後'
  end
end

