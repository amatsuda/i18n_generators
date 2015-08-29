require 'test_helper'
require 'generators/i18n_translation/i18n_translation_generator'

class I18nTranslationGeneratorTest < Test::Unit::TestCase
  setup do
    @generator = I18nTranslationGenerator.new(['ja'])
  end

  test 'each_value' do
    pend

    hash = ActiveSupport::OrderedHash.new
    hash[:parent1] = ActiveSupport::OrderedHash.new
    hash[:parent1][:child1] = 'child one'
    hash[:parent2] = ActiveSupport::OrderedHash.new
    hash[:parent2][:child2] = 'child two'
    hash[:parent2][:child3] = 'child three'
    subject.send(:each_value, [], hash) do |parents, value|
      p "#{parents.join('.')} #{value}"
    end
  end
end
