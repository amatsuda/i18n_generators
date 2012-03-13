# coding: utf-8
$KCODE = 'U'

require 'spec_helper'
require 'generators/i18n_translation/lib/translator'

describe I27r::Translator do
  subject { I27r::Translator.new 'ja' }

  describe 'when successfully translated' do
    before do
      subject.stub!(:_translate).and_return('こんにちは')
    end

    it 'returns translated text' do
      subject.translate('hello').should == 'こんにちは'
    end
  end

  describe 'when translation failed with error code' do
    before do
      subject.stub!(:_translate).and_return('')
    end

    it 'returns the original text' do
      subject.translate('hello').should == 'hello'
    end
  end

  describe 'when translation raised an error' do
    before do
      subject.stub!(:_translate).and_raise('ERROR!')
    end

    it 'returns the original text' do
      subject.translate('hello').should == 'hello'
    end
  end
end
