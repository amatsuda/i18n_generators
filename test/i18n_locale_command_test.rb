require 'test_helper'
require 'generators/i18n_locale/i18n_locale_generator'

class I18nLocaleGeneratorTest < Test::Unit::TestCase
  sub_test_case 'ja locale' do
    setup do
      @generator = I18nLocaleGenerator.new(['ja'])
    end

    sub_test_case 'add_locale_config' do
      test 'when i18n.default_locale is configured in environment.rb' do
        config = <<-CONFIG
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = :de
  end
end
CONFIG

        assert_equal <<-RESULT, @generator.send(:add_locale_config, config)
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = :ja
  end
end
RESULT
      end

      test 'when i18n.default_locale config is commented in environment.rb' do
        config = <<-CONFIG
module Tes
  class Application < Rails::Application
    # config.i18n.default_locale = :de
  end
end
CONFIG

        assert_equal <<-RESULT, @generator.send(:add_locale_config, config)
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = :ja
  end
end
RESULT
      end

      test 'when i18n.default_locale is not written in environment.rb' do
        config = <<-CONFIG
module Tes
  class Application < Rails::Application
    something goes here.
    bla bla bla...
  end
end
CONFIG

        assert_equal <<-RESULT, @generator.send(:add_locale_config, config)
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = :ja
    something goes here.
    bla bla bla...
  end
end
RESULT
      end
    end
  end

  sub_test_case 'zh-CN locale' do
    setup do
      @generator = I18nLocaleGenerator.new(['zh-CN'])
    end

    sub_test_case 'add_locale_config' do
      test 'when i18n.default_locale is configured in environment.rb' do
        config = <<-CONFIG
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = :de
  end
end
CONFIG

        assert_equal <<-RESULT, @generator.send(:add_locale_config, config)
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = :'zh-CN'
  end
end
RESULT
      end

      test 'when i18n.default_locale config is commented in environment.rb' do
        config = <<-CONFIG
module Tes
  class Application < Rails::Application
    # config.i18n.default_locale = :de
  end
end
CONFIG

        assert_equal <<-RESULT, @generator.send(:add_locale_config, config)
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = :'zh-CN'
  end
end
RESULT
      end

      test 'when i18n.default_locale is not written in environment.rb' do
        config = <<-CONFIG
module Tes
  class Application < Rails::Application
    something goes here.
    bla bla bla...
  end
end
CONFIG

        assert_equal <<-RESULT, @generator.send(:add_locale_config, config)
module Tes
  class Application < Rails::Application
    config.i18n.default_locale = :'zh-CN'
    something goes here.
    bla bla bla...
  end
end
RESULT
      end
    end
  end
end
