require 'rails_generator'
require 'rails_generator/commands'
require 'rubygems'
require 'gettext'
require File.join(File.dirname(__FILE__), 'i18n/lib/yaml')
require File.join(File.dirname(__FILE__), 'i18n/lib/cldr')
include I18nGeneratorModule

module I18nGenerator::Generator
  module Commands #:nodoc:
    module Create
      def execute(locale_name)
        template 'i18n_config.rb', 'config/initializers/i18n_config.rb', :assigns => {:locale_name => locale_name}

        GetText.bindtextdomain 'rails'
        GetText.locale = locale_name

        # active_support
        cldr = CldrDocument.new locale_name
        open_yaml('active_support', locale_name) do |yaml|
          yaml[locale_name].descendant_nodes do |node|
            v = cldr.lookup(node.path)
            node.value = v if !v.nil? && !(v.is_a?(Array) && v.any? {|e| e.nil?})
          end
        end

        # active_record
        open_yaml('active_record', locale_name) do |yaml|
          yaml[locale_name]['activerecord']['errors']['messages'].children.each do |node|
            unless node.value.nil?
              node.value = transfer_format('%{fn} ' + node.value.gsub('{{count}}', '%d')) do |v|
                GetText._(v)
              end
            end
          end
        end

        # action_view
        open_yaml('action_view', locale_name) do |yaml|
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
      def open_yaml(filename_base, locale_name)
        original_yml = I18n.load_path.detect {|lp| lp =~ /\/lib\/#{filename_base}\/locale\/en-US\.yml$/}
        doc = YamlDocument.new(original_yml, locale_name)
        yield doc
        file('base.yml', "lib/locale/#{filename_base}_#{locale_name}.yml") do |f|
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

