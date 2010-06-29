
require 'plist4r/mixin/haml4r/css_attributes'

module Haml4r
  class TableCell

    class InnerCell
      Attributes = Haml4r::CssAttributes + %w[ content ]

      def initialize *args, &blk
        @content = nil
      end

      def respond_to? method_sym
        return true if Attributes.include? method_sym.to_s
        return true if Attributes.include? method_sym.to_s.chomp('=')
        super
      end

      def method_missing method_sym, *args, &blk
        if Attributes.include? method_sym.to_s.chomp('=')
          set_or_return method_sym.to_s, *args, &blk
        end
      end

      def set attribute, value
        eval "@#{attribute} = value"
      end

      def value_for attribute
        eval "@#{attribute}"
      end

      def set_or_return attribute, value=nil
        case attribute
        when /\=$/
          set attribute.to_s.chomp('='), value
        else
          value_for attribute.to_s
        end
      end
    end

    Attributes = InnerCell::Attributes

    def initialize *args, &blk

      @inner_cell = InnerCell.new
      @table_section = nil

      case args[0]
      when nil

      when Hash, Haml4r::TableCell
        merge! args[0]

      else
        raise "unsupported type"
      end
    end

    def attributes_hash
      h = {}
      CssAttributes.Attributes.each do |a|
        v = self.send a
        h[a] = v if v
      end
      h
    end

    def merge! obj
      case obj
      when Hash
        Attributes.each do |a|
          hash = obj
          if hash[a.to_sym]
            value = hash[a.to_sym].deep_clone
            self.send( (a+'=').to_sym, value)
          end
        end
      when Haml4r::TableCell
        Attributes.each do |a|
          value = args[0].send(a.to_sym).deep_clone
          self.send( (a+'=').to_sym, value)
        end
      else
        raise "unsupported type"
      end
    end
    
    def to_hash
      @hash ||= {}
      Attributes.each do |a|
        @hash[a.to_sym] = eval "#{a}"
      end
      @hash
    end

    def inspect
      content ? content.inspect : super.match(/TableCell:[\w]*/)[0]
      # spanee ? "spanee" : ( content ? content.inspect : super.match(/TableCell:[\w]*/)[0] )
    end

    def inner_cell= inner_cell
      case inner_cell
      when InnerCell
        @inner_cell = inner_cell
      else
        raise "unsupported type"
      end
    end
    
    def inner_cell
      @inner_cell
    end

    def method_missing method_sym, *args, &blk
      if @inner_cell.class::Attributes.include? method_sym.to_s.chomp('=')
        @inner_cell.send method_sym, *args, &blk
      end
    end

    def spanee
      @spanee ||= false
    end

    def spanee= spanee
      case spanee
      when true, false
        @spanee = spanee
      else
        raise "unsupported type"
      end
    end

    def spaner
      @spaner ||= false
    end

    def spaner= spaner
      case spaner
      when true, false
        @spaner = spaner
      else
        raise "unsupported type"
      end
    end

    def dissolve_span!
      if spanee
        @inner_cell = @inner_cell.deep_clone
        @spanee = false
      else
        @spaner = false
      end
    end

  end

end
