module Plist4r
  # A module which is an instance of the Script class encapsulates in its scope
  # the top-level methods, top-level constants, and instance variables defined in
  # a ruby script file (and its subfiles) loaded by a ruby program. This allows
  # use of script files to define objects that can be loaded into a program in
  # much the same way that objects can be loaded from YAML or Marshal files.
  #
  # See intro.txt[link:files/intro_txt.html] for an overview.
  # 
  # Usable under the Ruby license. Copyright (C)2004 Joel VanderWerf. Questions to
  # mailto:vjoel@users.sourceforge.net.
  class Script < Module
    # The file with which the Script was instantiated.
    attr_reader :__main_file

    # The directory in which main_file is located, and relative to which
    # #load searches for files before falling back to Kernel#load.
    attr_reader :__dir
  
    # A hash that maps <tt>filename=>true</tt> for each file that has been
    # required locally by the script. This has the same semantics as <tt>$"</tt>,
    # alias <tt>$LOADED_FEATURES</tt>, except that it is local to this script.
    attr_reader :__loaded_features

    class << self
      alias load new
    end
  
    # Creates new Script, and loads _main_file_ in the scope of the Script. If a
    # block is given, the script is passed to it before loading from the file, and
    # constants can be defined as inputs to the script.
  
    def initialize(main_file)   # :yields: self
      extend ScriptModuleMethods
      @__main_file = File.expand_path(main_file)
      @__dir = File.dirname(@__main_file)
      @__loaded_features = {}
    
      yield self if block_given?
      load_in_module(@__main_file)
    end
  
    # Loads _file_ into this Script. Searches relative to the local dir, that is,
    # the dir of the file given in the original call to
    # <tt>Script.load(file)</tt>, loads the file, if found, into this Script's
    # scope, and returns true. If the file is not found, falls back to
    # <tt>Kernel.load</tt>, which searches on <tt>$LOAD_PATH</tt>, loads the file,
    # if found, into global scope, and returns true. Otherwise, raises
    # <tt>LoadError</tt>.
    #
    # The _wrap_ argument is passed to <tt>Kernel.load</tt> in the fallback case,
    # when the file is not found locally.
    #
    # Typically called from within the main file to load additional sub files, or
    # from those sub files.
  
    def load(file, wrap = false)
      load_in_module(file)
      true
    rescue MissingFile
      super
    end

    # Analogous to <tt>Kernel#require</tt>. First tries the local dir, then falls
    # back to <tt>Kernel#require</tt>. Will load a given _feature_ only once.
    #
    # Note that extensions (*.so, *.dll) can be required in the global scope, as
    # usual, but not in the local scope. (This is not much of a limitation in
    # practice--you wouldn't want to load an extension more than once.) This
    # implementation falls back to <tt>Kernel#require</tt> when the argument is an
    # extension or is not found locally.
  
    def require(feature)
      unless @__loaded_features[feature]
        @__loaded_features[feature] = true
        file = feature
        file += ".rb" unless /\.rb$/ =~ file
        load_in_module(file)
      end
    rescue MissingFile
      @__loaded_features[feature] = false
      super
    end
  
    # Raised by #load_in_module, caught by #load and #require.
    class MissingFile < LoadError; end
  
    # Loads _file_ in this module's context. Note that <tt>\_\_FILE\_\_</tt> and
    # <tt>\_\_LINE\_\_</tt> work correctly in _file_.
    # Called by #load and #require; not normally called directly.
  
    def load_in_module(__file__)
      __file__ = File.expand_path(__file__, @__dir)
      module_eval("@__script_scope ||= binding\n" + IO.read(__file__),
        __file__, 0)
        # start numbering at 0 because of the extra line.
        # The extra line does nothing in sub-script files.
    rescue Errno::ENOENT
      if /#{__file__}$/ =~ $!.message # No extra locals in this scope.
        raise MissingFile, $!.message
      else
        raise
      end
    end
  
    def to_s # :nodoc:
      "#<#{self.class}:#{File.join(__dir, File.basename(__main_file))}>"
    end

    module ScriptModuleMethods
      # This is so that <tt>def meth...</tt> behaves like in Ruby's top-level
      # context. The implementation simply calls
      # <tt>Module#module_function(name)</tt>.
      def method_added(name) # :nodoc:
        module_function(name)
      end
    
      attr_reader :__script_scope

      # Gets list of local vars in the script. Does not see local vars in files
      # loaded or required by that script.
      def __local_variables
        eval("local_variables", __script_scope)
      end
    
      # Gets value of local var in the script. Does not see local vars in files
      # loaded or required by that script.
      def __local_variable_get(name)
        eval(name.to_s, __script_scope)
      end
    end
  end
end