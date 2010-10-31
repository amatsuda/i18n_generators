require File.join(File.dirname(__FILE__), 'lib/yaml')
require File.join(File.dirname(__FILE__), 'lib/translator')

class I18nTranslationGenerator < Rails::Generators::NamedBase
  # option: include_timestamps
  def main
    unless file_name =~ /^[a-zA-Z]{2}([-_][a-zA-Z]+)?$/
      log 'ERROR: Wrong locale format. Please input in ?? or ??-?? format.'
      exit
    end
    log "translating models to #{locale_name}..."
    I18n.locale = locale_name

    keys = aggregate_keys
    translations = translate_all(keys)

    yaml = I27r::YamlDocument.load_yml_file "config/locales/translation_#{locale_name}.yml"
    each_value [], translations do |parents, value|
      if value.is_a? String
        yaml[[locale_name.to_s] + parents] = value
      else
        value.each do |key, val|
          yaml[[locale_name.to_s] + parents + [key]] = val
        end
      end
    end

    unless (yaml_string = yaml.to_s(true)).blank?
      create_file "config/locales/translation_#{locale_name}.yml", yaml_string
    end
  end

  private
  def aggregate_keys
    models = model_filenames.map do |model_name|
      model = begin
        m = model_name.camelize.constantize rescue LoadError
        next if m.nil? || !m.table_exists? || !m.respond_to?(:content_columns)
        m.class_eval %Q[def self._english_name; "#{model_name}"; end]
        m
      rescue
        next
      end
    end.compact

    translation_keys = []
    translation_keys += models.map {|m| "activerecord.models.#{m._english_name}"}
    models.each do |model|
      cols = model.content_columns + model.reflect_on_all_associations
      cols.delete_if {|c| %w[created_at updated_at].include? c.name} unless include_timestamps?
      translation_keys += cols.map {|c| "activerecord.attributes.#{model._english_name}.#{c.name}"}
    end
    translation_keys
  end

  # receives an array of keys and returns :key => :translation hash
  def translate_all(keys)
    translator = I27r::Translator.new locale_name.sub(/\-.*/, '')

    ActiveSupport::OrderedHash.new.tap do |oh|
      # fix the order first(for multi thread translating)
      keys.each do |key|
        if key.to_s.include? '.'
          key_prefix, key_suffix = key.to_s.split('.')[0...-1], key.to_s.split('.')[-1]
          key_prefix.inject(oh) {|h, k| h[k] ||= ActiveSupport::OrderedHash.new}[key_suffix] = nil
        else
          oh[key] = nil
        end
      end
      threads = []
      keys.each do |key|
        threads << Thread.new do
          Rails.logger.debug "translating #{key} ..."
          Thread.pass
          if key.to_s.include? '.'
            key_prefix, key_suffix = key.to_s.split('.')[0...-1], key.to_s.split('.')[-1]
            existing_translation = I18n.backend.send(:lookup, locale_name, key_suffix, key_prefix)
            key_prefix.inject(oh) {|h, k| h[k]}[key_suffix] = existing_translation ? existing_translation : translator.translate(key_suffix)
          else
            existing_translation = I18n.backend.send(:lookup, locale_name, key)
            oh[key] = existing_translation ? existing_translation : translator.translate(key)
          end
        end
      end
      threads.each {|t| t.join}
    end
  end

  def locale_name
    @_locale_name ||= file_name.gsub('_', '-').split('-').each.with_index.map {|s, i| i == 0 ? s : s.upcase}.join('-')
  end

  def include_timestamps?
    !!@include_timestamps
  end

  def model_filenames
    Dir.chdir("#{Rails.root}/app/models/") do
      Dir["**/*.rb"].map {|m| m.sub(/\.rb$/, '')}
    end
  end

  # iterate through all values
  def each_value(parents, src, &block)
    src.each do |k, v|
      if v.is_a?(ActiveSupport::OrderedHash)
        each_value parents + [k], v, &block
      else
        yield parents + [k], v
      end
    end
  end
end
