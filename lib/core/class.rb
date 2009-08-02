# size <= ssize *always* or something is severely wrong.
def __new_class_object(size,superclass,ssize)
  ob = 0
  %s(assign ob (malloc (mul size 4))) # Assumes 32 bit
  i = 1
#  %s(printf "class object: %p (%d bytes) / Class: %p / super: %p / size: %d\n" ob size Class superclass ssize)
#  %s(puts "")
  %s(while (lt i ssize) (do
       (assign (index ob i) (index superclass i))
       (assign i (add i 1))
  ))
  %s(while (lt i size) (do
       (assign (index ob i) __method_missing)
       (assign i (add i 1))
  ))
  %s(assign (index ob 0) Class)
  ob
end

class Class

  def new
    # @instance_size is generated by the compiler. YES, it is meant to be
    # an instance var, not a class var
    size = @instance_size
    %s(assign size (mul size 4))
    %s(assign ob (malloc size))
    %s(assign (index ob 0) self)
    %s(callm ob initialize ())
    ob
  end

  # FIXME
  # &block will be a "bare" %s(lambda) (that needs to be implemented),
  # define_method needs to attach that to the vtable (for now) and/or
  # to a hash table for "overflow" (methods lacking vtable slots).
  # This requires a painful decision:
  #
  # - To type-tag Symbol or not to type-tag
  #
  # It also means adding a function to look up a vtable offset from
  # a symbol, which effetively means a simple hash table implementation
  #
  def define_method sym, &block
    %s(puts "define_method")
  end

  # FIXME: Should handle multiple symbols
  def attr_accessor sym
    attr_reader sym
    attr_writer sym
  end
  
  def attr_reader sym
    %s(printf "attr_reader %d\n" sym)
    define_method sym do
       %s(ivar self sym) # FIXME: Create the "ivar" s-exp directive.
    end
  end

  def attr_writer sym
    %s(printf "attr_writer %d\n" sym)
    define_method "#{sym.to_s}=".to_sym do |val|
      %s(assign (ivar self sym) val)
    end
  end
end

