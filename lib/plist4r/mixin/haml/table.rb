
require 'plist4r/mixin/haml/table_section'


module Plist4r
	module Haml

    # A Table is composed of 3 sub-tables. The table of Column Headers, the table of Row Headers,
    # and the body of the table, the table data. Its the responsibility of the Table to render all 
    # Table Sections into html/xhtml, with to_s method.
    # 
    # The three tables are laid out by TableView as follows:
    # 
    #   :------------------------------------------:
    #   |                     :------------------: |
    #   |                     |                  | |
    #   |                     |                  | |
    #   |                     |   TableSection   | |
    #   |                     |   @col_headers   | |
    #   |                     |                  | |
    #   |                     |                  | |
    #   |                     :------------------: |
    #   | :------------------::------------------: |
    #   | |                  ||                  | |
    #   | |                  ||                  | |
    #   | |   TableSection   ||   TableSection   | |
    #   | |   @row_headers   ||   @body          | |
    #   | |                  ||                  | |
    #   | |                  ||                  | |
    #   | :------------------::------------------: |
    #   |                   Table                  |
    #   :------------------------------------------:
    # Note: The row header TableSection can be set with CSS attributes. 
    # However there is no overall HTML element for row headers, 
    # Therefore we cannot apply the row_headers css attributes.
    #       
    class Table

      def to_s
        require 'haml'
        engine = ::Haml::Engine.new self.haml
        rendered_html_output = engine.render self
      end

      def haml
        @haml ||= <<-'EOC'
%table{:class => self.css_class, :id => self.css_id, :style => self.css_style}
  - if @col_header
    %thead{:class => @col_header.css_class, :id => @col_header.css_id, :style => @col_header.css_style}
      - @col_header.row_range.each do |row|
        %tr
          - if @row_header
            - @row_header.col_range.each do |col|
              %th &nbsp;
          - @col_header.col_range.each do |col|
            - c = @col_header.cell col, row
            - unless c.spanee
              %th{:class => c.css_class, :id => c.css_id, :style => c.css_style, :colspan => @col_header.colspan(col,row), :rowspan => @col_header.rowspan(col,row)} #{c.content}
  - if @body
    %tbody{:class => @body.css_class, :id => @body.css_id, :style => @body.css_style}
      - @body.row_range.each do |row|
        %tr
          - if @row_header
            - @row_header.col_range.each do |col|
              - c = @row_header.cell col, row
              - unless c.spanee
                %th{:class => c.css_class, :id => c.css_id, :style => c.css_style, :colspan => @row_header.colspan(col,row), :rowspan => @row_header.rowspan(col,row)} #{c.content}
          - @body.col_range.each do |col|
            - c = @body.cell col, row
            - unless c.spanee
              %td{:class => c.css_class, :id => c.css_id, :style => c.css_style, :colspan => @body.colspan(col,row), :rowspan => @body.rowspan(col,row)} #{c.content}
EOC
      end

      include CssAttributes
      Attributes += %w[ col_header row_header body ]
      
      def initialize *args, &blk
        @body = TableSection.new *args, &blk
        @col_header, @row_header = [TableSection.new,TableSection.new]
      end

      def method_missing method_sym, *args, &blk
        if Attributes.include? method_sym.to_s.chomp('=')
          set_or_return method_sym.to_s, *args, &blk

        elsif @body.respond_to? method_sym
          @body.send method_sym, *args, &blk

        else
          super
        end
      end

      def transpose
        @col_header, @row_header = @row_header, @col_header
        @col_header.transpose
        @row_header.transpose
        @body.transpose
        self
      end

      def respond_to? method_sym
        return true if Attributes.include? method_sym.to_s.chomp('=')
        return true if @body.respond_to? method_sym
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
        col0 = 0
        cha,ba = [0,0]

        unless row_header.empty?
          col0 += row_header.ascii_col_width
          bw = body.ascii_col_width
          chw = col_header.ascii_col_width

          if bw > chw
            cha += (bw-chw)/2
          elsif chw > bw
            ba += (chw-bw)/2
          end
        end

        b = body.inspect(start_col+col0+ba).split "\n"

        unless row_header.empty?
          rh = row_header.inspect(start_col).split "\n"
          (0..([rh.size, b.size].min-1)).each do |i|
            b[i][0,col0] = rh[i][0,col0]
          end
        end

        if col_header.empty?
          return b.join("\n") + "\n"
        else
          return col_header.inspect(start_col+col0+cha) + b.join("\n") + "\n"
        end
      end

    end

  end
end
