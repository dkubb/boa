# typed: strong
# frozen_string_literal: true

module Boa
  # Abstract class for types
  class Type
    extend T::Sig
    extend T::Helpers
    include Equality

    abstract!

    # The name of the instance variable
    #
    # @example
    #   type.name  # => :first_name
    #
    # @return [Symbol] the name of the instance variable
    #
    # @api public
    sig { returns(Symbol) }
    attr_reader :name

    # The required flag of the type
    #
    # @example
    #   type.required  # => true
    #
    # @return [Boolean] the required flag of the type
    #
    # @api public
    sig { returns(T::Boolean) }
    attr_reader :required

    # @example
    #   type.required?  # => true
    #
    # @return [Boolean] the required flag of the type
    #
    # @api public
    alias required? required

    # The default value of the type
    #
    # @example
    #   type.default  # => 'Jon'
    #
    # @return [Object] the default value of the type
    #
    # @api public
    sig { returns(::Object) }
    attr_reader :default

    # The object to check inclusion against
    #
    # @example
    #   type.includes  # => nil
    #
    # @return [Object] the object to check inclusion against
    #
    # @api public
    sig { returns(::Object) }
    attr_reader :includes

    # The name of the instance variable
    #
    # @example
    #   type.ivar_name  # => :@first_name
    #
    # @return [Symbol] the name of the instance variable
    #
    # @api public
    sig { returns(Symbol) }
    attr_reader :ivar_name

    # Initialize the type
    #
    # @param name [Symbol] the name of the type
    # @param required [Boolean] whether the type is required
    # @param default [Object] the default value of the type
    # @param includes [Object] the object to check inclusion against
    # @param ivar_name [Symbol] the name of the instance variable
    #
    # @yield [] the block to instance_eval
    #
    # @return [void]
    #
    # @api private
    sig { params(name: Symbol, required: T::Boolean, default: ::Object, includes: ::Object, ivar_name: Symbol).void }
    def initialize(name, required: true, default: nil, includes: nil, ivar_name: :"@#{name}")
      @name      = name
      @required  = required
      @default   = T.let(default, T.nilable(::Object))
      @includes  = T.let(includes, T.nilable(::Object))
      @ivar_name = ivar_name
    end

    # Initialize the attribute in the instance
    #
    # @example with no attributes
    #   type.get(instance)   # => nil
    #   type.init(instance)  # => type   # set the default value
    #   type.get(instance)   # => 'Jon'
    #
    # @example with attributes
    #   type.get(instance)                       # => nil
    #   type.init(instance, first_name: 'Alex')  # => type  # set the value
    #   type.get(instance)                       # => 'Alex'
    #
    # @param instance [::Object] the instance to initialize
    # @param attributes [Hash{Symbol => ::Object}] the attributes to initialize with
    #
    # @return [Type] the type
    #
    # @api public
    sig { params(instance: ::Object, attributes: ::Object).returns(T.self_type) }
    def init(instance, **attributes)
      value = attributes.fetch(name) { default }
      set(instance, value)
    end

    # Get the value of the attribute from the instance
    #
    # @example when the value is not set
    #   type.get(instance)  # => nil  # get the value
    #
    # @example when the value is set
    #   type.set(instance, 'Alex')  # => type
    #   type.get(instance)          # => 'Alex'  # get the value
    #
    # @param instance [::Object] the instance to get the value from
    #
    # @return [::Object] the value of the attribute
    #
    # @api public
    sig { params(instance: ::Object).returns(::Object) }
    def get(instance)
      instance.instance_variable_get(ivar_name)
    end

    # Set the value of the attribute in the instance
    #
    # @example
    #   type.get(instance)          # => nil
    #   type.set(instance, 'Alex')  # => type    # set the value
    #   type.get(instance)          # => 'Alex'
    #
    # @param instance [::Object] the instance to set the value in
    # @param value [::Object] the value to set
    #
    # @return [Type] the type
    #
    # @api public
    sig { params(instance: ::Object, value: ::Object).returns(T.self_type) }
    def set(instance, value)
      instance.instance_variable_set(ivar_name, value)
      self
    end

    # Add methods to the descendant
    #
    # @example
    #   descendant.new.respond_to?(:first_name)  # => false
    #   type.add_methods(descendant)             # => type
    #   descendant.new.respond_to?(:first_name)  # => true
    #
    # @param descendant [Module] the class to add the methods to
    #
    # @return [Type] the type
    #
    # @api public
    sig { params(descendant: Module).returns(T.self_type) }
    def add_methods(descendant)
      add_reader(descendant)
    end

    # Finalize the type
    #
    # @example
    #   type.frozen?   # => false
    #   type.finalize  # => type   # freeze the type
    #   type.frozen?   # => true
    #
    # @return [Type] the type
    #
    # @api public
    sig { returns(T.self_type) }
    def finalize
      freeze
    end

    private

    # Add a reader method to the descendant
    #
    # @param descendant [Module] the class to add the method to
    #
    # @return [Type] the type
    #
    # @api private
    sig { params(descendant: Module).returns(T.self_type) }
    def add_reader(descendant)
      type = self
      descendant.define_method(name) do
        type.get(T.bind(self, ::Object))
      end
      type
    end
  end
end
