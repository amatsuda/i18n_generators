# coding: utf-8
require 'test_helper'
require 'generators/i18n_translation/lib/yaml'

class I27r::YamlDocumentTest < Test::Unit::TestCase
  sub_test_case 'when loading an existing file' do
    setup do
      @yaml_string = <<YAML
ja:
  hoge:
    fuga: piyo  #g
    numbers:
      one: "いち"  #g
      two: "に"

    aaa:
      foo: "ふー"
      bar: "ばー"
YAML
      @yaml = I27r::YamlDocument.new @yaml_string
    end

    test 'it exists' do
      assert_not_nil @yaml
    end

    test 'to_s' do
      assert_equal @yaml_string, @yaml.to_s
    end

    test '[]' do
      assert_equal 'piyo', @yaml['ja', 'hoge', 'fuga']
      assert_equal 'piyo', @yaml[['ja', 'hoge', 'fuga']]
    end

    test 'find_line_by_path' do
      assert_equal 'piyo', @yaml.find_line_by_path(['ja', 'hoge', 'fuga']).value
    end

    test 'find_line_by_path (-1)' do
      line = @yaml.find_line_by_path(['ja', 'aho', 'hage'], -1, true)

      assert_not_nil line
      assert_equal 'hage', line.key
      assert_nil line.value
    end

    sub_test_case '[]=' do
      test 'rewriting an existing value' do
        @yaml['ja', 'hoge', 'fuga'] = 'puyo'
        assert_equal 'puyo',  @yaml['ja', 'hoge', 'fuga']
      end

      test 'an existing value without #g mark' do
        @yaml['ja', 'hoge', 'numbers', 'two'] = 'ツー'
        assert_equal 'に',  @yaml['ja', 'hoge', 'numbers', 'two']
      end

      test 'creating a new node in the middle' do
        @yaml['ja', 'hoge', 'numbers', 'three'] = 'さん'
        assert_equal 'さん', @yaml['ja', 'hoge', 'numbers', 'three']
        assert_equal <<YAML, @yaml.to_s
ja:
  hoge:
    fuga: piyo  #g
    numbers:
      one: "いち"  #g
      two: "に"
      three: さん  #g

    aaa:
      foo: "ふー"
      bar: "ばー"
YAML
      end

      test 'creating a new node at the bottom' do
        @yaml['ja', 'aho', 'hage'] = 'hige'
        assert_equal 'hige', @yaml['ja', 'aho', 'hage']
      end
    end
  end

  test 'when loading an existing file with alias' do
    pend

    @yaml_string = <<YAML
ja:
  activerecord:
    attributes:
      hoge: &hoge
        foo: FOO
        bar: BAR
      hoge2: &hoge2
        hoge:
        <<:  *hogege
YAML
    @yaml = I27r::YamlDocument.new @yaml_string
    @yaml['ja', 'activerecord', 'hoge2', 'hoge'] = 'foo'

    puts @yaml.to_s
  end

  test 'creating a new file' do
    pend

    yaml = I27r::YamlDocument.new
    yaml['ja', 'hoge', 'fuga'] = 'piyo'
    yaml['ja', 'hoge', 'foo'] = 'bar'
    puts yaml
  end
end
