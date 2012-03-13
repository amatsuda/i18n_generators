require 'spec_helper'
require 'generators/i18n_locale/i18n_locale_generator'

describe I18nLocaleGenerator do
  subject { I18nLocaleGenerator.new(['ja']) }

  describe 'add_locale_config' do
    describe 'when i18n.default_locale is configured in environment.rb' do
      before do
        @config = "
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = :de
  end
end"
      end

      it 'rewrites the existing default_locale to locale_name value' do
        subject.send(:add_locale_config, @config).should == "
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = 'ja'
  end
end"
      end
    end

    describe 'when i18n.default_locale config is commented in environment.rb' do
      before do
        @config = "
module Tes
  class Application < Rails::Application
    # config.i18n.default_locale = :de
  end
end"
      end

      it 'uncomments the existing commented i18n config and sets locale_name value' do
        subject.send(:add_locale_config, @config).should == "
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = 'ja'
  end
end"
      end
    end

    describe 'when i18n.default_locale is not written in environment.rb' do
      before do
        @config = "
module Tes
  class Application < Rails::Application
    something goes here.
    bla bla bla...
  end
end"
      end

      it 'adds the default_locale config inside the config block and sets locale_name value' do
        subject.send(:add_locale_config, @config).should == "
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = 'ja'
    something goes here.
    bla bla bla...
  end
end"
      end
    end
  end
end
