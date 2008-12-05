$KCODE = 'U'

require File.join(File.dirname(__FILE__), '../generators/i18n_translation/lib/translator')
include I18nTranslationGeneratorModule

describe Translator do
  before(:each) do
    @translator = Translator.new 'ja'
  end

  describe 'when successfully translated' do
    before do
      res_200 = mock('res_200')
      res_200.stub!(:read).and_return('{"responseData": {"translatedText":"こんにちは"}, "responseDetails": null, "responseStatus": 200}')
    end

    it 'returns translated text' do
      @translator.translate('hello').should == 'こんにちは'
    end
  end

  describe 'when translation failed with error code' do
    before do
      res_500 = mock('res_500')
      res_500.stub!(:read).and_return('{"responseData": {"translatedText":"こんにちは？"}, "responseDetails": null, "responseStatus": 500}')
      OpenURI.stub!(:open_uri).and_return(res_500)
    end

    it 'returns the original text' do
      @translator.translate('hello').should == 'hello'
    end
  end

  describe 'when translation raised an error' do
    before do
      OpenURI.stub!(:open_uri).and_raise('ERROR!')
    end

    it 'returns the original text' do
      @translator.translate('hello').should == 'hello'
    end
  end
end

