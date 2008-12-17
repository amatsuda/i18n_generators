require File.join(File.dirname(__FILE__), '/../generators/i18n/lib/yaml')
include I18nLocaleGeneratorModule

describe 'Yaml' do
  before :each do
    @yaml = YamlDocument.new File.join(File.dirname(__FILE__), 'data/yml/active_record/en-US.yml'), 'ja'
  end

  describe YamlDocument do
    it 'should return the top level node with the square bracket method' do
      node = @yaml['ja']
      node.should be_an_instance_of(Node)
      node.key.should == 'ja'
    end

    it 'should generate a path string on the top node' do
      @yaml['ja'].path.should == '/ja'
    end
  end

  describe Node do
    before do
      @node = Node.new @yaml, 100, 'foo: bar'
    end

    it 'should return a key string from input text' do
      @node.key.should == 'foo'
    end

    it 'should return a value string from input text' do
      @node.value.should == 'bar'
    end

    it 'should generate a path string on any node' do
      @yaml['ja']['activerecord']['errors']['messages'].path.should == '/ja-JP/activerecord/errors/messages'
    end
  end
end

