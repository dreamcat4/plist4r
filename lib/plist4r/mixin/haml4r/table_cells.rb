
require 'plist4r/mixin/table'
require 'plist4r/mixin/haml4r/table_cell'

module Haml4r
  # TableCells object holds its table data in a 2-dimensional array.
  # TableCells inherits from Plist4r::Table, a generic table class.
  # 
  # We access cell locations in a col,row cartesian format (x,y).
  # Ie increasing columns numbers across to the right, and rows down.
  # 
  # To specify multiple cells, we use ranges to mark out a rectangle.
  # Any integer is translated to a range. For example row 3 => (3..3)
  # 
  # To specify a 2x2 square, we might write [(0..1),(0..1)], or
  # [(3..4),(5..6)] if the rectangle were to start at location [3,5]
  # and extend to [4,6] inclusive.
  # 
  # Internal table data always starts writing at index 0, and unused areas
  # padded with EmptyCell. We cannot store negative index locations.
  # 
  # For a table starting at a higher (non-zero) index, lower values are then ignored.
  # 
  # TableCells class includes spanning functionality, to accomodate the html
  # colspan= and rowspan= attributes. Spanning data are held in a special @spans
  # array, and individual cells are marked as spanning cells.
  # 
  # Certain table operations will change groups of cells at once. If a spanning
  # cell falls on the area of cells being changed, the span will try to be 
  # re-located, or operated upon in-place accordingly. However if the operation
  # breaks the boundaries of the spanning cell, it must be dissolved.
  # 
  # This is expecially true for functions such as transpose, which will flip the
  # orientation of cells across the x-y axis. Other operations, such as fill and
  # and col_insert imply that any existing spans in those areas not be preserved.
  # 
  #   :-----------------------------------------:
  #   | :------------------:------------------: |
  #   | |                  |                  | |
  #   | |                  |                  | |
  #   | |    TableCell     |    TableCell     | |
  #   | |                  |                  | |
  #   | |                  |                  | |
  #   | :------------------:------------------: |
  #   | |                  |                  | |
  #   | |                  |                  | |
  #   | |    TableCell     |    TableCell     | |
  #   | |                  |                  | |
  #   | |                  |                  | |
  #   | :- @array ---------:------------------: |
  #   |                TableCells               |
  #   :-----------------------------------------:
  # 
  class TableCells < Plist4r::Table

    def examples
      @table.cell(0,3).spanee
      @table.cell(0,3).css_class = "highline"
      @table.cells.cell(0,3).css_class = "highline"

      @table.cells
      # => TableCells obj (0,0) -> (max,max)

      @table.cell(0,0).attributes(:css_class, "highlighted")
      # => TableCell obj (0,0) -> (0,0)

      @table.cells(0,(0..3)).class = "highline"
      # => TableCells obj (0,0) -> (0,3)

      @table.cells.class = "highline"
      @table.cells.resize(5,5)

      @table.cell(2, 5, cell)

      quarant_a = @table.cells(0,(0..3))
      # => TableCells obj
    end

    OptionsHash += %w[ spans ]
    EmptyCell = TableCell.new

    def initialize *args, &blk
      @spans = nil
      super
      pad @cr, @rr, EmptyCell
      # puts "@spans = #{@spans.inspect}"
      # puts "args = #{args.inspect}"
      @spans ||= []
      refresh_spans
    end

    def empty?
      if @cr == (0..0) && @rr == (0..0)
        c = cell(0,0)
        TableCell::Attributes.each do |a|
          return false if eval("c.#{a}")
        end
        return true
      else
        return false
      end
    end

    def inspect start_col=0
      cell_width = Plist4r::Table.new :size => [@cr, 0..0], :fill_all => 5
      @cr.each do |col|
        @rr.each do |row|
          cell_size = @array[col][row].inspect.size
          cell_width.cell(col, 0, cell_size) if cell_size > cell_width.cell(col,0)
        end
      end

      col_pad_pre  = " "
      col_pad_post = " "

      vert_border = "|"
      horz_border = "-"

      # row_sep = ""
      # row_sep << " " * start_col
      # @cr.each do |col|
      #   row_sep << ":" + horz_border * (col_pad_pre.size + cell_width.cell(col,0) + col_pad_post.size)
      # end
      # row_sep << ":"

      o = ""
      # o << row_sep << "\n"
      @rr.each do |row|
        row_sep = ""
        row_sep << " " * start_col
        @cr.each do |col|
          last = cell(col,row-1)
          if last.is_a?(TableCell) && ( last.inner_cell == cell(col,row).inner_cell )
            row_sep << ":" + " " * (col_pad_pre.size + cell_width.cell(col,0) + col_pad_post.size)
          else
            row_sep << ":" + horz_border * (col_pad_pre.size + cell_width.cell(col,0) + col_pad_post.size)
          end
        end
        row_sep << ":"
        o << row_sep << "\n"



        o << " " * start_col
        @cr.each do |col|
          last = cell(col-1,row)
          if last.is_a?(TableCell) && ( last.inner_cell == cell(col,row).inner_cell )
            cell_str = " " * vert_border.size + col_pad_pre + " " * cell_width.cell(col,0) + col_pad_post
          else
            cell_str = vert_border + col_pad_pre + " " * cell_width.cell(col,0) + col_pad_post
          end
          cell_str[vert_border.size+col_pad_pre.size,@array[col][row].inspect.size] = @array[col][row].inspect
          o << cell_str
        end
        o << vert_border
        o << "\n"

      end
      row_sep = ""
      row_sep << " " * start_col
      @cr.each do |col|
        row_sep << ":" + horz_border * (col_pad_pre.size + cell_width.cell(col,0) + col_pad_post.size)
      end
      row_sep << ":"

      o << row_sep << "\n"
      return o
    end

    def resize col_range, row_range
      super
      pad @cr, @rr, EmptyCell
      inverse_unspan_cells if @spans
      self
    end

    def array array=nil
      result = super
      @spans.slice!(0,@spans.size) if @spans
      result
    end

    def spans spans=nil
      case spans
      when nil
        @spans
      when Array
        @spans = spans
      else
        raise "unsupported type"
      end
    end

    def colspan col, row
      @spans.each do |span|
        if span.col_range.first == col && span.row_range.first == row
          if span.col_range.size > 1
            return span.col_range.size
          end
        end
      end
      return nil
    end

    def rowspan col, row
      @spans.each do |span|
        if span.col_range.first == col && span.row_range.first == row
          if span.row_range.size > 1
            return span.row_range.size
          end
        end
      end
      return nil
    end

    def cell col, row, value=nil
      case value
      when Hash
        super col, row, TableCell.new(value)
      when nil, TableCell, Plist4r::Table
        super col, row, value
      else
        raise "unsupported type"
      end
    end

    def cells col_range=nil, row_range=nil, value=nil
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      replace col_range, row_range, value if value
      Haml4r::TableCells.new :array => @array, :size => [col_range, row_range], :spans => @spans
    end

    def span_cells col_range=nil, row_range=nil, data=nil
        col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
        col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

        puts "returning nil" unless col_range.size > 1 || row_range.size > 1
        return nil unless col_range.size > 1 || row_range.size > 1

        unspan_cells col_range, row_range

        if data
          cell col_range.first, row_range.first, data
        end

        first_cell = cell col_range.first, row_range.first
        first_cell.spaner = true
        spanning_inner_cell = first_cell.inner_cell

        new_span = cells col_range, row_range
        new_span.each do |c|
          unless c.spaner
            c.inner_cell = spanning_inner_cell
            c.spanee = true
          end
        end
        @spans << new_span
        self
    end

    def refresh_spans
      @spans.each do |span|
        first_cell = cell span.col_range.first, span.row_range.first
        first_cell.spaner = true
        spanning_inner_cell = first_cell.inner_cell

        span.each do |c|
          unless c.spaner
            c.inner_cell = spanning_inner_cell
            c.spanee = true
          end
        end
      end
      self
    end

    def crop col_range, row_range
      crop_obj = super
      cs = col_range.first
      rs = row_range.first

      @spans.each do |span|
        scr, srr = [span.col_range, span.row_range]
        cf, cl   = [scr.first - cs, scr.last - cs]
        rf, rl   = [srr.first - rs, srr.last - rs]

        if cf < 0 || rf < 0
          crop_cr = ([cf,0].max)..([cl,0].max)
          crop_rr = ([rf,0].max)..([rl,0].max)
          crop_obj.each(crop_cr, crop_rr) do |c|
            c.dissolve_span!
          end
        else
          crop_obj.span_cells cf..cl, rf..rl
        end
      end
      crop_obj.inverse_unspan_cells
      return crop_obj
    end

    def fill col_range, row_range, data
      super
      unspan_cells col_range, row_range
      self
    end

    def inverse_fill col_range, row_range, data=nil
      super
      inverse_unspan_cells col_range, row_range
      self
    end

    def transpose col_range=nil, row_range=nil, keep_bounds=false
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      super_cr, super_rr = [col_range, row_range]

      ocr,orr = [col_range,row_range]
      col_range = (ocr.begin)..(ocr.begin+orr.size-1)
      row_range = (orr.begin)..(orr.begin+ocr.size-1)

      if keep_bounds && col_range.size != row_range.size
        if ocr.size > orr.size
          row_range = (row_range.begin)..(orr.end)
        else
          col_range = (col_range.begin)..(ocr.end)
        end
      end

      transposed_spans = []
      @spans.each do |span|
        ocr,orr = [span.col_range,span.row_range]
        nscr = (ocr.begin)..(ocr.begin+orr.size-1)
        nsrr = (orr.begin)..(orr.begin+ocr.size-1)
        if ( nscr & col_range == nscr ) && ( nsrr & row_range == nsrr )
          transposed_spans << [nscr,nsrr]
        end
      end

      unspan_cells col_range, row_range
      super super_cr, super_rr
      pad super_cr, super_rr, EmptyCell

      transposed_spans.each do |ts|
        span_cells ts[0], ts[1]
      end

      self
    end

    def data_replace col_range, row_range, other_data
      super
      unspan_cells col_range, row_range

      col_adjust = col_range.first-other_data.col_range.first
      row_adjust = row_range.first-other_data.row_range.first

      o_spans = other_data.spans
      o_spans.each do |span|
        scr, srr = [span.col_range, span.row_range]
        sacr = (scr.first+col_adjust)..(scr.last+col_adjust)
        sarr = (srr.first+row_adjust)..(srr.last+row_adjust)

        col_multiply = col_range & sacr
        row_multiply = row_range & sarr

        span_cells sacr, sarr if col_multiply == sacr && row_multiply == sarr
      end
      self
    end

    def unspan_cells col_range=nil, row_range=nil
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      conflicting_spans = []
      @spans.each do |span|
        col_overlap = col_range & span.col_range
        row_overlap = row_range & span.row_range
        conflicting_spans << span if col_overlap && row_overlap
      end

      conflicting_spans.each do |span|
        span.each do |c|
          c.dissolve_span!
        end
        @spans.delete span
      end

      self
    end

    def inverse_unspan_cells col_range=nil, row_range=nil
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range
      
      conflicting_spans = []
      @spans.each do |span|
        col_multiply = col_range & span.col_range
        row_multiply = row_range & span.row_range
        conflicting_spans << span unless col_multiply == span.col_range && row_multiply == span.row_range
      end
      
      conflicting_spans.each do |span|
        span.each do |c|
          c.dissolve_span!
        end
        @spans.delete span
      end
      self
    end

    def respond_to? method_sym
      return true if TableCell::Attributes.include? method_sym.to_s.chomp('=')
      super
    end

    def method_missing method_sym, *args, &blk
      if TableCell::Attributes.include? method_sym.to_s.chomp('=')
        set_or_return method_sym.to_s.chomp('='), *args, &blk
      end
    end

    def map col_range=nil, row_range=nil, &blk
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      t = Plist4r::Table.new :size => [col_range, row_range]

      row_range.each do |row|
        col_range.each do |col|
          element = yield(cell(col, row).deep_clone)
          t.cell col, row, element
        end
      end
      refresh_spans
      t
    end

    def map! col_range=nil, row_range=nil, &blk
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      row_range.each do |row|
        col_range.each do |col|
          c = cell(col, row).deep_clone
          element = yield c
          if element.is_a? TableCell
            cell col, row, element
          else
            cell col, row, c
          end
        end
      end
      refresh_spans
      t
    end

    def set attribute, value
      set_or_return attribute, value        
    end

    def value_for attribute
      set_or_return attribute
    end

    def set_or_return attribute, value=nil
      case value
      when nil
        map do |cell|
          eval "cell.#{attribute}"
        end
      else
        each do |cell|
          eval "cell.#{attribute} = value"
        end
      end
    end

  end

end
