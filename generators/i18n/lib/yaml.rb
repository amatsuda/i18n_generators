require 'yaml'

module I18nLocaleGeneratorModule
  class Node
    attr_reader :document, :indent_level
    attr_accessor :line

    def initialize(parent, line_index, text)
      @document, @line, @text = parent.document, line_index, text.to_s
      @text =~ /(^\s*)/
      @indent_level = $1.nil? ? 0 : $1.size
      @yaml = YAML.load(@text.to_s + ' ')
    end

    def parent
      @parent ||= document.parent_of self
    end

    def children
      @children ||= document.children_of(self)
    end
    alias :nodes :children

    def [](node_name)
      if node = nodes.detect {|n| n.key.to_s == node_name.to_s}
        node
      else
        nodes.add "#{' ' * (@indent_level + 2)}#{node_name}: "
        nodes.last
      end
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
    alias :to_s :text

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

    def <=>(other)
      self.line <=> other.line
    end
  end

  class YamlDocument < Node
    attr_accessor :lines
    alias :nodes :lines

    def initialize(yml_path, locale_name)
      @locale_name, @lines, @current_line, @indent_level = locale_name, Nodes.new(self), -1, -2
      if File.exists? yml_path
        File.open(yml_path) do |file|
          file.each_with_index do |line_text, i|
            n = Node.new(self, i, line_text.chomp)
            @lines << ((((n.key == 'en-US') || (n.key == 'en')) && n.value.blank?) ? Node.new(self, i, "#{locale_name}:") : n)
          end
          @lines.delete_at(-1) if @lines[-1].text.blank?
        end
      end
    end

    def next
      return false if @lines.size == 0
      @current_line += 1
      return false if @current_line >= @lines.size
      @lines[@current_line].is_blank_or_comment? ? self.next : @lines[@current_line]
    end

    def prev
      return false if @current_line == 0
      @current_line -= 1
      @lines[@current_line].is_blank_or_comment? ? self.prev : @lines[@current_line]
    end

    def parent_of(child)
      @current_line = child.line
      while n = self.prev
        return n if n.indent_level == child.indent_level - 2
      end 
      self
    end

    def children_of(parent)
      nodes = Nodes.new(parent)
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

    def document
      self
    end

    def path
      ''
    end

    def line
      @current_line
    end

    def to_s
      @lines.inject('') do |ret, n|
        ret << n.text + "\n"
      end
    end
  end

  class Nodes < Array
    def initialize(parent)
      super()
      @parent = parent
    end

    def [](index)
      if index.is_a?(String) || index.is_a?(Symbol)
        return self.detect {|node| node.key == index} || add(index)
      end
      super
    end

    def last_leaf
      c = @parent
      loop do
        return c if c.children.blank?
        c = c.children.last
      end
    end

    def add(node_name)
      target_line = self.last_leaf.line + 1
      @parent.document.nodes.each {|n| n.line += 1 if n.line >= target_line}
      node = Node.new(@parent, target_line, node_name)
      @parent.document.lines << node
      @parent.document.lines.sort!
      self << node unless @parent.is_a? YamlDocument
    end
  end
end

