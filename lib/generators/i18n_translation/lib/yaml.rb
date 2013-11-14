begin
  require 'psych'
rescue LoadError
  require 'generators/i18n_translation/lib/yaml_waml'
end

module I27r
  class Line
    attr_reader :text
    delegate :scan, :to => :@text

    def initialize(text, options = {})
      @generated = !!options[:generated] || text.end_with?('  #g')
      @yaml = YAML.load text.to_s + ' '
      @text = text
    end

    def key
      yaml? ? @yaml.keys.first : nil
    end

    def value
      yaml? ? @yaml.values.first : nil
    end

    def indent
      yaml? ? @text.scan(/^ */).first : ''
    end

    def generated?
      @generated
    end

    def yaml?
      @yaml.is_a?(Hash) && @yaml.keys.first.is_a?(String)
    end

    def value=(val)
      if @yaml[self.key] != val
        @yaml[self.key] = val
        generate_text self.indent
      end
    end

    def to_s
      "#{@text}#{'  #g' if generated? && yaml? && !value.nil? && !@text.end_with?('  #g')}"
    end

    private
    def generate_text(indent)
      @text = indent + @yaml.to_yaml.sub(/--- ?\n/, '').chomp.rstrip
    end
  end

  class YamlDocument
    attr_accessor :root

    def initialize(yaml = '')
      @lines = yaml.split("\n").map {|s| Line.new s}
    end

    def self.load_yml_file(yml_path)
      if File.exist? yml_path
        self.new File.read(yml_path)
      else
        self.new
      end
    end

    def [](*path)
      find_line_by_path(path.flatten).try :value
    end

    def find_line_by_path(path, line_num = -1, add_new = false)
      key = path.shift
      indent = line_num == -1 ? '' : @lines[line_num].scan(/^ */).first + '  '
      @lines[(line_num + 1)..-1].each do |line|
        line_num += 1
        next unless line.yaml?

        if (line.indent == indent) && (line.key == key)
          if path.empty?
            return line
          else
            return find_line_by_path path, line_num, add_new
          end
        elsif line.indent < indent
          if add_new
            new_line = Line.new("#{indent}#{key}:", :generated => true)
            if @lines[line_num - 1].try(:text) == ''
              @lines.insert line_num - 1, new_line
            else
              @lines.insert line_num, new_line
            end
            return new_line if path.empty?
            return find_line_by_path path, line_num, add_new
          else
            return
          end
        end
      end
      if add_new
        new_line = Line.new("#{indent}#{key}:", :generated => true)
        @lines.insert @lines.count, new_line
        return new_line if path.empty?
        return find_line_by_path path, @lines.count - 1, add_new
      end
    end

    def []=(*args)
      value = args.pop
      path = args.flatten
#       return if value && (value == self[path])

      line = find_line_by_path path.dup
      if line
        if line.generated?
          line.value = value
        end
      else
        line = find_line_by_path path, -1, true
        line.value = value
      end
    end

    def to_s(add_blank_line = false)
      previous_indent = ''
      ''.tap do |ret|
        @lines.each do |line|
          ret << "\n" if add_blank_line && (line.indent < previous_indent) && !line.to_s.blank? && !ret.end_with?("\n\n")
          previous_indent = line.indent
          ret << line.to_s << "\n"
        end
      end
    end
  end
end
