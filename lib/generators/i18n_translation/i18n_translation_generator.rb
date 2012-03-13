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
    Rails.application.eager_load!

    model_names_translations = order_hash translate_all(model_names_keys)
    attribute_names_translations = order_hash translate_all(attribute_names_keys)
    translations = model_names_translations.deep_merge attribute_names_translations

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
  def models
    @models ||= ActiveRecord::Base.descendants.map do |m|
      begin
        m if m.table_exists? && m.respond_to?(:content_columns)
      rescue => e
        p e
        next
      end
    end.compact
  end

  def model_names_keys
    models.map {|m| "activerecord.models.#{m.model_name.underscore}"}
  end

  def attribute_names_keys
    models.map {|model|
      cols = model.content_columns + model.reflect_on_all_associations
      cols.delete_if {|c| %w[created_at updated_at].include? c.name} unless include_timestamps?
      cols.map {|c| "activerecord.attributes.#{model.model_name.underscore}.#{c.name}"}
    }.flatten
  end

  def translator
    @translator ||= I27r::Translator.new locale_name.sub(/\-.*/, '')
  end

  # receives an array of keys and returns :key => :translation hash
  def translate_all(keys)
    ret, threads = {}, []
    keys.each do |key|
      threads << Thread.new do
        Rails.logger.debug "translating #{key} ..."
        Thread.pass
        key_prefix, key_suffix = key.to_s.split('.')[0...-1], key.to_s.split('.')[-1]
        existing_translation = I18n.backend.send(:lookup, locale_name, key_suffix, key_prefix)
        ret[key] = existing_translation ? existing_translation : translator.translate(key_suffix)
      end
    end
    threads.each {|t| t.join}
    ret
  end

  def locale_name
    @_locale_name ||= file_name.gsub('_', '-').split('-').each.with_index.map {|s, i| i == 0 ? s : s.upcase}.join('-')
  end

  def include_timestamps?
    !!@include_timestamps
  end

  # transform a Hash into a nested OrderedHash
  def order_hash(hash)
    ActiveSupport::OrderedHash.new.tap do |oh|
      hash.sort_by {|k, _v| k}.each do |key, value|
        if key.to_s.include? '.'
          key_prefix, key_suffix = key.to_s.split('.')[0...-1], key.to_s.split('.')[-1]
          key_prefix.inject(oh) {|h, k| h[k] ||= ActiveSupport::OrderedHash.new}[key_suffix] = value
        else
          oh[key] = value
        end
      end
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
