require 'spec_helper'
require 'generators/i18n_translation/i18n_translation_generator'

describe I18nTranslationGenerator do
  subject { I18nTranslationGenerator.new(['ja']) }

  describe 'each_value' do
    xit 'iterates through each value' do
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
end
