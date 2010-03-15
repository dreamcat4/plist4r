# class_attributes.rb - Class Attributes
# A Feature-complete alternative to @@

class Object
  def deep_clone; Marshal::load(Marshal.dump(self)); end
end

module ClassAttributes

  def cattr(*args, &block)
    (class << self; self; end).class_eval do
      attr_accessor *args
    end
    @cattr ||= []
    @cattr.concat(args)
  end

  def iattr(*args, &block)
    (class << self; self; end).class_eval do
      attr_accessor *args
    end
    @iattr ||= []
    @iattr.concat(args)
  end

  def oattr(*args, &block)
    (class << self; self; end).class_eval do
      attr_accessor *args
    end
    @oattr ||= []
    @oattr.concat(args)
  end

  def oattr_i(*args, &block)
    (class << self; self; end).class_eval do
      attr_accessor *args
    end
    @oattr_i ||= []
    @oattr_i.concat(args)
  end

  def co_attr(*args, &block)
    cattr(*args,&block)
    oattr(*args,&block)    
  end

  def co_attr_i(*args, &block)
    iattr(*args,&block)
    oattr_i(*args,&block)
  end

  alias_method :class_inherited_attribute_shared,                 :cattr
  alias_method :class_inherited_attribute_independant,            :iattr

  alias_method :object_inherited_attribute_shared,                :oattr
  alias_method :object_inherited_attribute_independant,           :oattr_i

  alias_method :class_and_object_shared_inherited_attribute,      :co_attr
  alias_method :class_and_object_independant_inherited_attribute, :co_attr_i

  def inherited(subclass)
    super(subclass) if respond_to?('super')
    iattr.each do |a|
      # puts "a=#{a}"
      subclass.send("#{a}=", send(a).deep_clone)
      subclass.send("iattr", a.to_sym)
    end
    cattr.each do |a|
      subclass.send("#{a}=", send(a))
      subclass.send("cattr", a.to_sym)
    end
    oattr.each do |a|
      subclass.send("oattr", a.to_sym)
    end
    oattr_i.each do |a|
      subclass.send("oattr_i", a.to_sym)
    end
    subclass.send(:inherit) if subclass.respond_to?('inherit')
  end

  def inherit(*args, &block)
    super if respond_to?('super')
  end
end

module ObjectPreInitialize
  private
  def pre_initialize(*args, &block)
    super if respond_to?('super')

    class_attrs = self.class.cattr + self.class.iattr

    self.class.oattr.each do |a|
      sac = self.class.send(a)
      eval "@#{a.to_s}=sac" if class_attrs.include? a
    end

    self.class.oattr_i.each do |a|
      sac = self.class.send(a)
      eval "@#{a.to_s}=sac.deep_clone" if class_attrs.include? a
    end
  end

  # def postinitialize(*args, &block)
  # end
end

module OverloadNew
  def new(*args, &block)
    newObj = self.allocate
    newObj.send :extend, ObjectPreInitialize
    newObj.send :pre_initialize, *args, &block
    newObj.send :initialize,     *args, &block
    # newObj.send :postinitialize, *args, &block
    return newObj
  end
end

def has_class_attributes
  extend ClassAttributes
end

def has_class_object_attributes
  extend ClassAttributes
  extend OverloadNew
end


