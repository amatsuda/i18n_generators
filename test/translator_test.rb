# coding: utf-8
$KCODE = 'U'

require 'test_helper'
require 'generators/i18n_translation/lib/translator'

class I27r::TranslatorTest < Test::Unit::TestCase
  setup do
    @translator = I27r::Translator.new 'ja'
  end

  test 'when successfully translated' do
    stub(@translator)._translate { 'こんにちは' }

    assert_equal 'こんにちは', @translator.translate('hello')
  end

  test 'when translation failed with error code' do
    stub(@translator)._translate { '' }

    assert_equal 'hello', @translator.translate('hello')
  end

  test 'when translation raised an error' do
    stub(@translator)._translate { raise 'ERROR!' }

    assert_equal 'hello', @translator.translate('hello')
  end
end
