require File.join(File.dirname(__FILE__), '/../generators/i18n_translation/i18n_translation_command')

describe I18nGenerator::Generator::Commands::Create do
  before do
    (@command = Object.new).extend I18nGenerator::Generator::Commands::Create
    @command.stub!(:locale_name).and_return('ja')
  end

  describe 'yamlizes a given Hash' do
    it 'yamlizes a simple hash' do
      hash = ActiveSupport::OrderedHash.new
      hash[:key] = 'value'
      @command.__send__(:yamlize, hash, 0).should == "key: value\n"
    end

    it 'yamlizes a nested hash' do
      hash = ActiveSupport::OrderedHash.new
      hash[:parent] = ActiveSupport::OrderedHash.new
      hash[:parent][:child] = 'child value'
      @command.__send__(:yamlize, hash, 0).should == "parent:\n  child: child value\n"
    end
  end
end

