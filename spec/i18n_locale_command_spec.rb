require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '/../generators/i18n_locale/i18n_locale_command')

describe I18nGenerator::Generator::Commands::Create do
  before do
    (@command = Object.new).extend I18nGenerator::Generator::Commands::Create 
    @command.stub!(:locale_name).and_return('ja')
  end

  describe 'add_locale_config' do
    describe 'when i18n.default_locale is configured in environment.rb' do
      before do
        @config = "
Rails::Initializer.run do |config|
  config.i18n.default_locale = :de
end"
      end

      it 'rewrites the existing default_locale to locale_name value' do
        @command.send(:add_locale_config, @config).should == "
Rails::Initializer.run do |config|
  config.i18n.default_locale = 'ja'
end"
      end
    end

    describe 'when i18n.default_locale config is commented in environment.rb' do
      before do
        @config = "
Rails::Initializer.run do |config|
  # config.i18n.default_locale = :de
end"
      end

      it 'uncomments the existing commented i18n config and sets locale_name value' do
        @command.send(:add_locale_config, @config).should == "
Rails::Initializer.run do |config|
  config.i18n.default_locale = 'ja'
end"
      end
    end

    describe 'when i18n.default_locale is not written in environment.rb' do
      before do
        @config = "
Rails::Initializer.run do |config|
  something goes here.
  bla bla bla...
end"
      end

      it 'adds the default_locale config inside the config block and sets locale_name value' do
        @command.send(:add_locale_config, @config).should == "
Rails::Initializer.run do |config|
  config.i18n.default_locale = 'ja'
  something goes here.
  bla bla bla...
end"
      end
    end
  end
end

