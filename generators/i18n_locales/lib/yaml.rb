require 'yaml'

module I18nLocalesGeneratorModule
  class YamlDocument
    def initialize(yml_path, locale_name)
      @locale_name, @nodes = locale_name, []
      File.read(yml_path).each_with_index do |line_text, i|
        n = Node.new(self, i, line_text.chomp)
        @nodes << (((n.key == 'en-US') || (n.key == 'en')) ? Node.new(self, i, "#{locale_name}:") : n)
      end
    end

    def next
      @current_line += 1
      return false if @current_line == @nodes.size
      @nodes[@current_line].is_blank_or_comment? ? self.next : @nodes[@current_line]
    end

    def prev
      return false if @current_line == 0
      @current_line -= 1
      @nodes[@current_line].is_blank_or_comment? ? self.prev : @nodes[@current_line]
    end

    def parent_of(child)
      @current_line = child.line
      while n = self.prev
        return n if n.indent_level == child.indent_level - 2
      end 
      self
    end

    def children_of(parent)
      nodes = Nodes.new
      @current_line = parent.line
      while n = self.next
        if n.indent_level < parent.indent_level + 2
          break
        elsif n.indent_level == parent.indent_level + 2
          nodes << n
        end
      end
      nodes
    end

    def [](node_name)
      @current_line = @nodes.detect {|n| (n.indent_level == 0) && (n.key == node_name)}.line
      @nodes[@current_line]
    end

    def document
      self
    end

    def path
      ''
    end

    def to_s
      @nodes.inject('') do |ret, n|
        ret << n.text + "\n"
      end
    end
  end

  class Node
    attr_reader :line, :indent_level

    def initialize(doc, line_index, text)
      @doc, @line, @text = doc, line_index, text
      @text =~ /(^\s*)/
      @indent_level = $1.nil? ? 0 : $1.size
      @yaml = YAML.load(@text + ' ')
    end

    def parent
      @parent ||= @doc.parent_of self
    end

    def children
      @children ||= @doc.children_of(self)
    end

    def [](node_name)
      children.detect {|c| c.key == node_name}
    end

    def key
      @yaml.is_a?(Hash) ? @yaml.keys.first : nil
    end

    def value
      @yaml.is_a?(Hash) ? @yaml.values.first : nil
    end

    def value=(val)
      if @yaml[self.key] != val
        @yaml[self.key] = val
        @changed = true
      end
    end

    def text
      if @changed
        v = if self.value.is_a?(Array)
          "[#{self.value * ', '}]"
        else
          %Q["#{self.value}"]
        end
        "#{' ' * self.indent_level}#{self.key}: #{v}"
      else
        @text
      end
    end

    def changed?
      @changed
    end

    def is_blank_or_comment?
      @text.sub(/#.*$/, '').gsub(/\s/, '').empty?
    end

    def path
      @path ||= "#{self.parent.path}/#{self.key}"
    end

    def descendant_nodes(&block)
      yield self if self.value
      self.children.each {|child| child.descendant_nodes(&block)} if self.children
    end
  end

  class Nodes < Array
    def[](index)
      return detect {|node| node.key == index} if index.is_a?(String)
      super
    end
  end
end

