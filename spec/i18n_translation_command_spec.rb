require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '/../generators/i18n_translation/i18n_translation_command')

describe I18nGenerator::Generator::Commands::Create do
  before do
    (@command = Object.new).extend I18nGenerator::Generator::Commands::Create
    @command.stub!(:locale_name).and_return('ja')
  end

  describe 'each_value' do
    it 'iterates through each value' do
      hash = ActiveSupport::OrderedHash.new
      hash[:parent1] = ActiveSupport::OrderedHash.new
      hash[:parent1][:child1] = 'child one'
      hash[:parent2] = ActiveSupport::OrderedHash.new
      hash[:parent2][:child2] = 'child two'
      hash[:parent2][:child3] = 'child three'
      @command.__send__(:each_value, [], hash) do |parents, value|
        p "#{parents.join('.')} #{value}"
      end
    end
  end
end

