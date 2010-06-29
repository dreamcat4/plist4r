require 'haml'
require 'plist4r/mixin/haml4r/table'

module Haml4r
  class TableExample

    def haml
      @haml ||= <<-'EOC'
%h1 Backend Test Matrix
%div
  %h3 Code to generate html table
  %pre{ :class => "code" } #{create_dynamic_table}
  %p Haml
  %pre{ :class => "code" } #{@table.haml}
  %h2 ** Generated Html **
  %h3 Dynamic table
  %p Inspect method (ascii representation)
  %pre{ :class => "code" } #{"&nbsp;\n" + @table.inspect + "&nbsp;\n"}
  %p Haml helper method
  %pre{ :class => "code" } = @table
  = @table
  %hr
  %h3 Dynamic table, transposed (flipped)
  %pre{ :class => "code" } - @table.transpose
  %p Inspect method (ascii representation)
  - @table.transpose
  %pre{ :class => "code" } #{"&nbsp;\n" + @table.inspect + "&nbsp;\n"}
  %p Haml helper method
  %pre{ :class => "code" } = @table
  = @table
%p
EOC
    end

    def to_s
      require 'haml'
      engine = ::Haml::Engine.new self.haml
      rendered_html_output = engine.render self
    end

    def create_dynamic_table
@create_dynamic_table ||= <<-'EOC'
t = Haml4r::Table.new :size => [1..3, 1..2]

t.col_range.each do |col|
  t.row_range.each do |row|
    t.cell(col,row).content = "val#{col}#{row}"
  end
end

t.col_header.size [t.body.col_range,1..2]
t.col_header.span_cells 1..3, 1, :content => "Open"

t.col_header.col_range.each do |col|
  t.col_header.cell(col,2).content = "x#{col}"
end

t.row_header.size [1,t.body.row_range]
t.row_header.row_range.each do |row|
  t.row_header.cell(1,row).content = "y#{row}"
end
@table = t
EOC
    end

    def initialize *args, &blk
      eval create_dynamic_table
    end

    def write_html_file
      docs_dir = File.dirname(__FILE__) + "/../../../lib/plist4r/docs"
      File.open "#{docs_dir}/BackendTestMatrix.html","w" do |o|
        o << to_s
      end
    end

  end
end

