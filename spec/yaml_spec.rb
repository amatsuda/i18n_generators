require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '../lib/generators/i18n_translation/lib/yaml')

describe I27r::YamlDocument do
  context 'when loading an existing file' do
    before do
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

    subject { @yaml }
    it { should be }

    its(:to_s) { should == @yaml_string }

    describe '[]' do
      specify '[]' do
        @yaml['ja', 'hoge', 'fuga'].should == 'piyo'
        @yaml[['ja', 'hoge', 'fuga']].should == 'piyo'
      end
    end

    describe 'find_line_by_path' do
      subject { @yaml.find_line_by_path(['ja', 'hoge', 'fuga']) }
      its(:value) { should == 'piyo' }
    end

    describe 'find_line_by_path' do
      subject { @yaml.find_line_by_path(['ja', 'aho', 'hage'], -1, true) }
      it { should be }
      its(:key) { should == 'hage' }
      its(:value) { should_not be }
    end

    describe '[]=' do
      context 'rewriting an existing value' do
        before { @yaml['ja', 'hoge', 'fuga'] = 'puyo' }
        subject { @yaml['ja', 'hoge', 'fuga'] }
        it { should == 'puyo' }
      end

      context 'an existing value without #g mark' do
        before { @yaml['ja', 'hoge', 'numbers', 'two'] = 'ツー' }
        subject { @yaml['ja', 'hoge', 'numbers', 'two'] }
        it { should == 'に' }
      end

      context 'creating a new node in the middle' do
        before { @yaml['ja', 'hoge', 'numbers', 'three'] = 'さん' }
        subject { @yaml['ja', 'hoge', 'numbers', 'three'] }
        it { should == 'さん' }
        specify do
          @yaml.to_s.should ==  <<YAML
ja:
  hoge:
    fuga: piyo  #g
    numbers:
      one: "いち"  #g
      two: "に"
      three: "さん"  #g

    aaa:
      foo: "ふー"
      bar: "ばー"
YAML
        end
      end

      context 'creating a new node at the bottom' do
        before { @yaml['ja', 'aho', 'hage'] = 'hige' }
        subject { @yaml['ja', 'aho', 'hage'] }
        it { should == 'hige' }
      end

    end
  end

  context 'when loading an existing file with alias' do
    before do
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
    end

    specify '' do
      puts @yaml.to_s
    end
  end

  context 'creating a new file' do
    before do

    end

    specify 'that' do
      yaml = I27r::YamlDocument.new
      yaml['ja', 'hoge', 'fuga'] = 'piyo'
      yaml['ja', 'hoge', 'foo'] = 'bar'
      puts yaml
    end
  end
end
