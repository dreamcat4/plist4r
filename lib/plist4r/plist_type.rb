
require 'plist4r/mixin/data_methods'

class Plist4r::PlistType
  include ::Plist4r::DataMethods

  def initialize opts, *args, &blk
    raise unless opts[:hash]
    @hash = @orig = opts[:hash]
  end
end

class Plist4r::ArrayDict
  include DataMethods

  def initialize orig, index=nil, &blk
    @orig = orig
    if index
      @enclosing_block = self.class.to_s.snake_case + "[#{index}]"
      @orig = @orig[index]
    else
      @enclosing_block = self.class.to_s.snake_case
    end
    puts "@orig = #{@orig.inspect}"
    puts "@enclosing_block = #{@enclosing_block}"

    @block = blk
    @hash = ::ActiveSupport::OrderedHash.new
    puts "@hash = #{@hash}"

    instance_eval(&@block) if @block
    puts "@hash = #{@hash}"
  end

  def hash
    @hash
  end

  def select *keys
    keys.each do |k|
      @hash[k] = @orig[k]
    end
  end

  def unselect *keys
    keys.each do |k|
      @hash.delete k
    end
  end

  def unselect_all
    @hash = ::ActiveSupport::OrderedHash.new
  end

  def select_all
    @hash = @orig
  end
end

