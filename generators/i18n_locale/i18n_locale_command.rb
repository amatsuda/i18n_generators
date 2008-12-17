require 'rubygems'
require 'rails_generator'
require 'rails_generator/commands'
require 'gettext'
require File.join(File.dirname(__FILE__), '../i18n/lib/yaml')
require File.join(File.dirname(__FILE__), 'lib/cldr')
include I18nLocaleGeneratorModule

module I18nGenerator::Generator
  module Commands #:nodoc:
    module Create
      def generate_configuration
        return if I18n.default_locale == locale_name
        if Rails.configuration.respond_to? :i18n  # >= 2.2.2
          # edit environment.rb file
          environment = add_locale_config File.read(File.join(Rails.root, 'config/environment.rb'))
          File.open File.join(Rails.root, 'config/environment.rb'), 'w' do |f|
            f.puts environment
          end
          puts "      update  config/environment.rb"
        else
          template 'i18n:i18n_config.rb', 'config/initializers/i18n_config.rb', :assigns => {:locale_name => locale_name}
        end
      end

      def fetch_from_rails_i18n_repository
        file('i18n:base.yml', "config/locales/#{locale_name}.yml") do |f|
          OpenURI.open_uri("http://github.com/svenfuchs/rails-i18n/tree/master/rails/locale/#{locale_name}.yml?raw=true").read
        end
      end

      def active_support_yaml
        open_yaml('active_support') do |yaml|
          yaml[locale_name].descendant_nodes do |node|
            v = cldr.lookup(node.path)
            node.value = v if !v.nil? && !(v.is_a?(Array) && v.any? {|e| e.nil?})
          end
        end
      end

      def active_record_yaml
        open_yaml('active_record') do |yaml|
          yaml[locale_name]['activerecord']['errors']['messages'].children.each do |node|
            unless node.value.nil?
              node.value = transfer_format('%{fn} ' + node.value.gsub('{{count}}', '%d')) do |v|
                GetText._(v)
              end
            end
          end
        end
      end

      def action_view_yaml
        open_yaml('action_view') do |yaml|
          yaml[locale_name]['datetime']['distance_in_words'].children.each do |node|
            if !node.value.nil?
              node.value = GetText._(node.value)
            elsif ((children = node.children).size == 2) && (children.map(&:key) == %w[one other])
              children['one'].value, children['other'].value = translate_one_and_other(children.map(&:value))
            end
          end
          yaml[locale_name]['activerecord']['errors']['template'].children.each do |node|
            if !node.value.nil?
              node.value = if node.value == 'There were problems with the following fields:'
                GetText.n_('There was a problem with the following field:', node.value, 2)
              else
                GetText._(node.value)
              end
            elsif ((children = node.children).size == 2) && (children.map(&:key) == %w[one other])
              children['one'].value, children['other'].value = if children['one'].value == '1 error prohibited this {{model}} from being saved'
                translate_one_and_other(['%{num} error prohibited this {{model}} from being saved', children['other']])
              else
                translate_one_and_other(children.map(&:value))
              end
            end
          end
          yaml[locale_name]['number'].descendant_nodes do |node|
            v = cldr.lookup(node.path)
            node.value = v if !v.nil? && !(v.is_a?(Array) && v.any? {|e| e.nil?})
          end
        end
      end

      private
      def add_locale_config(environment_contents)
        (arr = environment_contents.split("\n")).each_with_index do |l, i|
          if l =~ /^\s*config\.i18n\.default_locale = /
            arr[i] = "  config.i18n.default_locale = '#{locale_name}'"
            return arr.join("\n")
          end
        end
        arr.each_with_index do |l, i|
          if l =~ /^\s*#?\s*config\.i18n\.default_locale = /
            arr[i] = "  config.i18n.default_locale = '#{locale_name}'"
            return arr.join("\n")
          end
        end
        arr.each_with_index do |l, i|
          if l =~ /Rails::Initializer\.run do \|config\|/
            arr[i] = "Rails::Initializer.run do |config|\n  config.i18n.default_locale = '#{locale_name}'"
            return arr.join("\n")
          end
        end
        end_row = RUBY_VERSION >= '1.8.7' ? arr.rindex {|l| l =~ /^\s*end\s*/} : arr.size - 1
        ((arr[0...end_row] << "  config.i18n.default_locale = '#{locale_name}'") + arr[end_row..-1]).join("\n")
      end

      def open_yaml(filename_base)
        original_yml = I18n.load_path.detect {|lp| lp =~ /\/lib\/#{filename_base}\/locale\/(en|en-US)\.yml$/}
        doc = YamlDocument.new(original_yml, locale_name)
        yield doc
        file('i18n:base.yml', "config/locales/#{filename_base}_#{locale_name}.yml") do |f|
          doc.to_s
        end
      end

      def transfer_format(args)
        vals = if args.is_a?(Array)
          args.map {|v| v.gsub('{{count}}', '%d').gsub('{{model}}', '%{record}')}
        else
          args.gsub('{{count}}', '%d').gsub('{{model}}', '%{record}')
        end
        result = yield vals
        result.gsub(/^%\{fn\}/, '').gsub('%d', '{{count}}').gsub('%{record}', '{{model}}').gsub('%{num}', '{{count}}').strip
      end

      def translate_one_and_other(values)
        values = values.map {|v| v.is_a?(Node) ? v.value : v}
        [transfer_format(values) {|v| GetText.n_(v.first, v.second, 1)}, transfer_format(values) {|v| GetText.n_(v.first, v.second, 2)}]
      end
    end
  end
end

