
require 'plist4r/mixin/haml/table_cells'

module Plist4r
	module Haml

    # A TableSection is a container object. Its responsibility is to forward messages to
    # the TableCells instance object. TableSection also holds css attributes for that 
    # sub-section (if applicable, these will be applied to thead, and tbody html tags).
    # 
    # The TableSection contains other instance objects.
    # 
    #   :----------------------------------------------------:
    #   |                                                    |
    #   |   :--------------------------------------------:   |
    #   |   |                                            |   |
    #   |   |  :-------------------:------------------:  |   |
    #   |   |  |                   |                  |  |   |
    #   |   |  |                   |                  |  |   |
    #   |   |  |    TableCell      |    TableCell     |  |   |
    #   |   |  |                   |                  |  |   |
    #   |   |  |                   |                  |  |   |
    #   |   |  :-------------------:------------------:  |   |
    #   |   |  |                   |                  |  |   |
    #   |   |  |                   |                  |  |   |
    #   |   |  |    TableCell      |    TableCell     |  |   |
    #   |   |  |                   |                  |  |   |
    #   |   |  |                   |                  |  |   |
    #   |   |  :- @array ----------:------------------:  |   |
    #   |   |                 TableCells                 |   |
    #   |   :- @cells -----------------------------------:   |
    #   |                    TableSection                    |
    #   :----------------------------------------------------:
    #       
		class TableSection

      def haml
        @haml ||= <<-'EOC'
%table
  %tbody{:class => self.css_class, :id => self.css_id, :style => self.css_style}
    - @cells.row_range.each do |row|
      %tr
        - @cells.col_range.each do |col|
          - c = @cells.cell col, row
          - unless c.spanee
            %td{:class => c.css_class, :id => c.css_id, :style => c.css_style, :colspan => @cells.colspan(col,row), :rowspan => @cells.rowspan(col,row)} #{c.content}
EOC
      end

      def to_s
        require 'haml'
        engine = ::Haml::Engine.new self.haml
        rendered_html_output = engine.render self
      end

      include CssAttributes

      def initialize *args, &blk
        @cells ||= TableCells.new *args, &blk
      end

      def method_missing method_sym, *args, &blk
        if Attributes.include? method_sym.to_s.chomp('=')
          set_or_return method_sym.to_s, *args, &blk

        elsif @cells.respond_to? method_sym
          @cells.send method_sym, *args, &blk

        else
          super
        end
      end

      def respond_to? method_sym
        return true if Attributes.include? method_sym.to_s.chomp('=')
        return true if @cells.respond_to? method_sym
        super
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

      def inspect start_col=0
        @cells.inspect start_col
      end
    end

  end
end
