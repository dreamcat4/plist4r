
require 'haml'
require 'plist4r/mixin/haml4r/table'

# def table
#   t = Haml4r::Table.new :size => [0..5, 0..5]
#   t.cell 0,0, "foo"
#   t.cell 0,0
# 
#   t.cell 2,0, "pineapples"
#   t.cell 4,0, "some_string"
#   t.fill 0..5, 1..4, 0
#   puts t.inspect
# end
# table



def haml4r_table
  # t = Haml4r::Table.new :size => [0..5, 0..5]
  # t.cell 0,0, "foo"
  # t.cell 0,0

  # t.cell 2,0, "pineapples"
  # t.cell 4,0, "some_string"
  # t.fill 0..5, 1..4, 0
  # puts t.inspect
  # puts ""

  # puts "col_range = #{t.col_range}"
  # puts "row_range = #{t.row_range}"
  # puts "size = #{t.size}.inspect"
  # puts ""
  
  # puts "pad_all \"empty\""
  # t.pad_all "empty"
  # puts t.inspect
  # puts ""
  
  # puts "crop 0..2, 0..2"
  # t2 = t.crop 0..2, 0..2
  # puts t2.inspect
  # puts ""

  # puts "fill 0..2, 1..2, \"fill\""
  # t.fill 0..2, 1..2, "fill"
  # puts t.inspect
  # puts ""

  # puts "fill_all, \"fill\""
  # t2.fill_all "fill"
  # puts t2.inspect
  # puts ""

  # puts "inverse_fill, 1..1, 1..1, \"inverse\""
  # # t2.inverse_fill 1..1, 1..1, "inverse"
  # t2.inverse_fill 1, 1, "inverse"
  # puts t2.inspect
  # puts ""

  # puts "t3"
  # fruit = %w[ apples strawberries banana grapefruit mango papaya]
  # day = %w[ mon tues wed thurs fri sat]
  # t3 = Haml4r::Table.new :size => [0..5, 0..5]
  # (0..5).each do |col|
  #   (0..2).each do |row|
  #     t3.cell col,row, fruit[col]
  #     # t3.cell col,row, "S " << (97+col).chr << " " << (97+row).chr
  #   end
  #   (3..5).each do |row|
  #     t3.cell col,row, day[col]
  #   end
  # end
  # puts t3.inspect
  # puts ""

  # puts "transpose"
  # t3.transpose
  # puts t3.inspect
  # puts ""
  # 
  # puts "transpose 3..5, 3..5"
  # t3.transpose 3..5, 3..5
  # puts t3.inspect
  # puts ""
  # 
  # puts "transpose 3..5, 3..5"
  # t3.transpose 3..5, 3..5
  # puts t3.inspect
  # puts ""
  # 
  # puts "transpose 0..3, 0..2"
  # t3.transpose 0..3, 0..2
  # puts t3.inspect
  # puts ""

  # puts "col_replace 0, (row 3)"
  # # t3.col_replace 0, t3.row(3)
  # t3.col_replace 0..1, "col 0..1"
  # # t3.col 0, t3.col(5)
  # puts t3.inspect
  # puts ""

  # puts "row_replace 0, (col 5)"
  # puts t3.col(5).transpose.inspect
  # t3.row_replace 1, t3.col(5).transpose
  # # t3.row_replace 1, "row 1"
  # puts t3.inspect
  # puts ""

  # puts "translate 0..2, 0..2, [3,3]"
  # t3.translate 0..2, 0..2, [3,3]
  # puts t3.inspect
  # puts ""

  # puts "t3.cells(0..1, 2..2)"
  # puts t3.cells(0..1,2..2).inspect
  # puts ""

  # puts "col_insert 3..4, 3..4, t3.cells(0..1, 2..2)"
  # t3.col_insert 3..4, 3..4, t3.cells(0..1,2..2)
  # puts t3.inspect
  # puts ""

end
# haml4r_table

def haml4r_haml_table_cells
  # t = Haml4r::TableCells.new :size => [0..3, 0..5]
  # puts t.inspect
  # puts ""
  # 
  # puts "t.each content = Date::DAYNAMES[i]"
  # i = 0
  # require 'date'
  # t.each 1..2, 1..3 do |c|
  #   c.content = Date::DAYNAMES[i]
  #   i +=1
  # end
  # puts t.inspect
  # puts ""
  # 
  # t.cell(1,1).content = "foos"
  # c = t.content
  # puts "t.content => #{c.class}"
  # puts c.inspect
  # puts c.cell(0,0).class
  # puts c.cell(1,1).class
  # puts ""
  # 
  # puts "t.content = \"depeche mode\""
  # t.content = "depeche mode"
  # puts t.inspect
  # puts t.cell(0,0).class
  # puts t.cell(1,1).class
  # puts ""
end
# haml4r_haml_table_cells

def haml4r_haml_table_cell
  # puts "table cell"
  # c = Haml4r::TableCell.new
  # puts c.inspect
  # puts ""
  # c.content = "jeremy"
  # puts c.inspect
  # puts ""
end
# haml4r_haml_table_cell

def haml4r_haml_table_cell_spans
  # t = Haml4r::TableCells.new :size => [0..3, 0..5]
  # # puts t.inspect
  # # puts ""
  # 
  # puts "t.each(1..2, 1..3) content = Date::DAYNAMES[i]"
  # i = 0
  # require 'date'
  # t.each 1..2, 1..3 do |c|
  #   c.content = Date::DAYNAMES[i]
  #   i +=1
  # end
  # puts t.inspect
  # puts ""
  # 
  # puts "t.span_cells 0..3, 4..5, :content => \"foos\""
  # t.span_cells 0..3, 4..5, :content => "foos"
  # puts t.inspect
  # puts ""
  # 
  # puts "t.cell(0,4).content = \"bar\""
  # t.cell(0,4).content = "bar"
  # t.cell(0,4).css_class = "bar"
  # t.cell(0,4).css_class += " of_trouble"
  # puts t.inspect
  # puts ""
  # 
  # puts "t.to_s"
  # puts t
  # puts ""
end
# haml4r_haml_table_cell_spans

def haml4r_haml_table
  t = Haml4r::Table.new :size => [1..3, 1..2]
  
  t.col_range.each do |col|
    t.row_range.each do |row|
      t.cell(col,row).content = "val#{col}#{row}"
    end
  end

  t.col_header = Haml4r::TableSection.new
  t.col_header.size [t.body.col_range,1..2]
  t.col_header.span_cells 1..3, 1, :content => "Open"
  t.col_header.col_range.each do |col|
    t.col_header.cell(col,2).content = "x#{col}"
  end
  
  t.row_header = Haml4r::TableSection.new
  t.row_header.size [1,t.body.row_range]
  t.row_header.row_range.each do |row|
    t.row_header.cell(1,row).content = "y#{row}"
  end
  
  puts t.inspect
  puts ""
  
  puts "t.to_s"
  puts t
  puts ""
end
# haml4r_haml_table

def haml4r_transpose_test
  t = Haml4r::Table.new :size => [0..6, 2..8]
  puts "strip = t.body.cells(1..5, 3..3) ; strip.span"
  strip = t.body.cells(1..5, 3..3)
  strip.span_cells
  # strip.first.content = "foo"
  strip.content = "foo"
  strip.cell(6,3).content = "james"

  strip.map!(1..6,3) do |c|
    c.content += " bar"
  end

  puts t.inspect
  puts ""

  puts "t.body.transpose 1..5,3..3"
  t.body.transpose 1..5, 3..3
  # t.body.transpose 1..4, 3..3
  # t.body.cell(1,7).content = "bar"
  puts t.body.inspect
  puts ""
  
end
# haml4r_transpose_test


