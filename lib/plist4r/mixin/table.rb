
require 'plist4r/mixin/ruby_stdlib'

module Plist4r
  
  # A data type representation for tables. The underlying store is an array of arrays (2d).
  # The addressing scheme is based on (column, row) order, with Range objects to specify 
  # the bounds of any rectangle of elements withing the table.
  # 
  # A variety of methods are provided for manipulating the table data, including flipping, 
  # inserting, replacing and deleting. Operations can be column-based, row-based, or both.
  class Table
    class << self
      # This class only understands a range addressing scheme, which is used to specify
      # table locations in a [columns, rows] caresian system starting at col 0, row 0.
      # 
      # Convert any Integer numbers into range objects. Check that all input ranges are 
      # positive, starting (and including) zero as the first index.
      def sanitize_ranges *ranges
        sanitized_ranges = []
        ranges.flatten.each do |range|
          case range
          when Range
            if range.exclude_end?
              range = range.first..(range.last - 1)
            end
          when Integer
            range = (range..range)
          else
            raise "Unsupported type"
          end
          if range.first < 0 || range.last < 0
            raise "range cannot cover negative values"
          end
          sanitized_ranges << range
        end
        sanitized_ranges
      end
    end

    # The value to assign to an empty cell
    EmptyCell  = nil

    # The range of valid values for which match the empty cell criteria (for which the cell are ignored)
    EmptyCells = [nil, false]

    # When allocating the arrays for a new table, the minimum size to pad around with empty cells.
    MinPadSize = 10

    OptionsHash = %w[ size array pad_all fill_all ]

    def initialize *args, &blk
      @array = []

      case args[0]
      when nil
        resize 0..0, 0..0

      when Hash
        parse_opts args[0]

      when Plist4r::Table
        %w[ col_range row_range array ].each do |a|
          self.send a.to_sym, args[0].send(a.to_sym).deep_clone
        end

      else
        raise "unsupported type"
      end

      resize 0..0, 0..0 unless @cr && @rr
    end

    # Sets up those valid (settable) attributes as found the options hash.
    # Normally we dont call this method directly. Called from {#initialize}.
    # @param [Hash <OptionsHash>] opts The options hash, containing keys of {OptionsHash}
    # @see #initialize
    def parse_opts opts
      self.class::OptionsHash.each do |opt|
        if opts[opt.to_sym]
          value = opts[opt.to_sym]
          eval "self.#{opt}(value)"
        end
      end
    end

    def ascii_col_width
      lines = self.inspect.split "\n"
      lines[0].length
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

      row_sep = ""
      row_sep << " " * start_col
      @cr.each do |col|
        row_sep << vert_border + horz_border * (col_pad_pre.size + cell_width.cell(col,0) + col_pad_post.size)
      end
      row_sep << vert_border

      o = ""
      o << row_sep << "\n"
      @rr.each do |row|
        o << " " * start_col
        @cr.each do |col|
          cell_str = vert_border + col_pad_pre + " " * cell_width.cell(col,0) + col_pad_post
          cell_str[vert_border.size+col_pad_pre.size,@array[col][row].inspect.size] = @array[col][row].inspect
          o << cell_str
        end
        o << vert_border
        o << "\n"
        o << row_sep << "\n"
      end
      return o
    end

    def col_range
      @cr
    end

    def row_range
      @rr
    end

    def cell col, row, value=nil
      raise "unsupported type" unless col.is_a?(Integer) && row.is_a?(Integer)
      return nil if col < 0 || row < 0

      case value
      when nil
        @array[col][row]
      else
        if value.is_a? Plist4r::Table
          @array[col][row] = value.cell col, row
        else
          @array[col][row] = value
        end
      end
    end

    def first value=nil
      cell @cr.first, @rr.first, value
    end

    def map col_range=nil, row_range=nil, &blk
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      t = Plist4r::Table.new :size => [col_range, row_range]
      row_range.each do |row|
        col_range.each do |col|
          t.cell col, row, yield(cell(col, row))
        end
      end
      t
    end

    def each col_range=nil, row_range=nil, &blk
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range
      row_range.each do |row|
        col_range.each do |col|
          yield cell(col, row)
        end
      end
    end

    def array array=nil
      case array
      when nil
        @array
      when Array
        if array.multidim?
          @array = array
          auto_size unless @cr && @rr
        else
          raise "array type not supported"
        end
      else
        raise "Unsupported type"
      end
    end

    def size *args
      if args.empty?
        [@cr, @rr]
      else
        col_range, row_range = args.flatten
        resize col_range, row_range
      end
    end

    def resize col_range, row_range
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      @cr = col_range
      @rr = row_range
      pad @cr, @rr, EmptyCell
    end

    def auto_size      
      ce = @array.size - 1
      unless @cr && (0..ce).include_range?(@cr)
        @cr = 0..ce
      end

      re = 0
      @array.each do |col|
        re = col.size - 1 if col.size - 1 > re
      end

      unless @rr && (0..re).include_range?(@rr)
        @rr = 0..re
      end
    end

    def pad col_range, row_range, data
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      if EmptyCells.include? data
        if col_range.end < MinPadSize - 1
          col_range = 0..(MinPadSize - 1)
        else
          col_range = 0..(col_range.end)
        end

        if row_range.end < MinPadSize - 1
          row_range = 0..(MinPadSize - 1)
        else
          row_range = 0..(row_range.end)
        end
      end

      (col_range.end - @array.size + 1).times do
        @array << []
      end

      col_range.each do |col|
        row_range.each do |row|
          @array[col][row] = data.deep_clone if EmptyCells.include? @array[col][row]
        end
      end
    end

    def pad_all data
      pad @cr, @rr, data
    end

    def crop col_range, row_range
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      pad col_range, row_range, EmptyCell
      crop_obj = self.class.new :size => [0..(col_range.size - 1), 0..(row_range.size - 1)]

      col_range.each do |col|
        row_range.each do |row|
          crop_obj.array[col-col_range.first][row-row_range.first] = @array[col][row].deep_clone
        end
      end
      crop_obj
    end

    def fill col_range, row_range, data=nil
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range
      data = EmptyCell unless data

      pad col_range, row_range, EmptyCell
      col_range.each do |c|
        row_range.each do |r|
          @array[c][r] = data.deep_clone
        end
      end
    end

    def fill_all data
      fill @cr, @rr, data
    end

    def inverse_fill col_range, row_range, data=nil
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range
      data = EmptyCell unless data

      crop_obj = crop col_range, row_range
      fill @cr, @rr, data
      replace col_range, row_range, crop_obj
    end

    def transpose col_range=nil, row_range=nil, keep_bounds=false
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      if col_range == @cr && row_range == @rr && @cr.first == @rr.first
        @array = @array.transpose
        if keep_bounds
          @cr,@rr = [[@cr,@rr].min,[@cr,@rr].min]
        else
          @cr,@rr = [@rr, @cr]
        end
        self
      else
        col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

        crop_obj = crop col_range, row_range
        crop_obj.transpose
        fill col_range, row_range, EmptyCell

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
        replace col_range, row_range, crop_obj
      end
      self
    end

    def data_replace col_range, row_range, other_data
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      self.pad col_range, row_range, EmptyCell
      o = other_data.deep_clone

      if o.col_range.size < col_range.size
        col_range = (col_range.first)..(row_range.first + o.col_range.size - 1)
      end

      if o.row_range.size < row_range.size
        row_range = (row_range.first)..(row_range.first + o.row_range.size - 1)
      end

      col_range.each do |col|
        row_range.each do |row|
          # @array[col][row] = o.array[col-col_range.first+o.col_range.first][row-row_range.first+o.row_range.first].deep_clone
          cell col, row, o.cell(col-col_range.first+o.col_range.first,row-row_range.first+o.row_range.first).deep_clone
        end
      end
    end

    def replace col_range, row_range, data
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      case data
      when Plist4r::Table
        data_replace col_range, row_range, data
      else
        fill col_range, row_range, data
      end
      self
    end

    def col_replace col_range, data
      col_range = Plist4r::Table.sanitize_ranges col_range
      replace col_range, @rr.first..@rr.last, data
    end

    def row_replace row_range, data
      row_range = Plist4r::Table.sanitize_ranges row_range
      replace @cr.first..@cr.last, row_range, data
    end

    def translate col_range, row_range, vector
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      crop_obj = crop col_range, row_range
      fill col_range, row_range, EmptyCell
      col_range = (col_range.begin+vector[0])..(col_range.end+vector[0])
      row_range = (row_range.begin+vector[1])..(row_range.end+vector[1])
      replace col_range, row_range, crop_obj
    end

    def col_insert col_range, row_range, other_data, resize=true
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range
      translate col_range.first..@cr.last, @rr, [col_range.size, 0]
      replace col_range, row_range, other_data
      @cr = @cr.first..(@cr.last + col_range.size) if resize
    end

    def row_insert col_range, row_range, other_data, resize=true
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range
      translate @cr, row_range.first..@rr.last, [0, row_range.size]
      replace col_range, row_range, other_data
      @rr = @rr.first..(@rr.last + row_range.size) if resize
    end

    def cells col_range=nil, row_range=nil, value=nil
      col_range = @cr if col_range.nil? ; row_range = @rr if row_range.nil?
      col_range, row_range = Plist4r::Table.sanitize_ranges col_range, row_range

      replace col_range, row_range, value if value
      self.class.new :array => @array, :size => [col_range, row_range]        
    end

    def col col_range, value=nil
      col_range = Plist4r::Table.sanitize_ranges col_range

      case value
      when nil
        cells col_range, @rr
      else
        col_replace col_range, value
      end
    end
    
    def row row_range, value=nil
      row_range = Plist4r::Table.sanitize_ranges row_range

      case value
      when nil
        cells @cr, row_range
      else
        row_replace row_range, value
      end
    end

  end
end
