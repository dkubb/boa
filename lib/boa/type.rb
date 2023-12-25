# typed: strong
# frozen_string_literal: true

module Boa
  # Abstract class for types
  class Type
    extend T::Helpers
    extend T::Sig
    include InstanceMethods

    # The class type alias
    ClassType = T.type_alias { T.anything }

    abstract!

    # Lookup the type for a class type
    #
    # @example when type class type is registered
    #   Boa::Type[::String] # => Boa::Type::String
    #
    # @example when type class type is unknown
    #   OtherClass = Class.new
    #   Boa::Type[OtherClass] # => raise ArgumentError, 'type class for Boa::Type::OtherClass is unknown'
    #
    # @param class_type [ClassType] the class type
    #
    # @return [Class<Type>] the type for the class type
    #
    # @api public
    sig { overridable.params(class_type: ClassType).returns(T.class_of(Type)) }
    def self.[](class_type)
      class_types.fetch(class_type) do
        raise(ArgumentError, "type class for #{class_type} is unknown")
      end
    end

    # Set the type for a class type
    #
    # @example
    #   Boa::Type[::String] = Boa::Type::String
    #   Boa::Type[::String] # => Boa::Type::String
    #
    # @param class_type [ClassType] the class type
    # @param descendant [Class<Type>] the type for the class type
    #
    # @return [Class<Type>] the type for the class type
    #
    # @api public
    sig { overridable.params(class_type: ClassType, descendant: T.class_of(Type)).returns(T.class_of(Type)) }
    def self.[]=(class_type, descendant)
      class_types[class_type] = descendant
    end

    # Set the class type for the type
    #
    # @example
    #   Boa::Type::String.class_type(::String) # => Boa::Type::String
    #   Boa::Type[::String]                    # => Boa::Type::String
    #
    # @param class_type [ClassType] the class type
    #
    # @return [Type] the type
    #
    # @api public
    sig { overridable.params(class_type: ClassType).returns(T.class_of(Type)) }
    def self.class_type(class_type)
      self[class_type] = self
    end

    # The class types
    #
    # @return [Hash{ClassType => Class<Type>}] the class types
    #
    # @api private
    sig { overridable.returns(T::Hash[ClassType, T.class_of(Type)]) }
    def self.class_types
      @class_types ||= T.let({}, T.nilable(T::Hash[ClassType, T.class_of(Type)]))
    end
    private_class_method(:class_types)

    # Hook called when a descendant inherits from this class
    #
    # @param descendant [Class<Type>] the class inheriting from this class
    #
    # @return [void]
    #
    # @api private
    sig { overridable.params(descendant: T.class_of(Type)).void }
    def self.inherited(descendant)
      # Share class_types with descendants
      descendant.instance_variable_set(:@class_types, class_types)

      super
    end
    private_class_method(:inherited)

    # The name of the instance variable
    #
    # @example
    #   type.name # => :first_name
    #
    # @return [Symbol] the name of the instance variable
    #
    # @api public
    sig { returns(Symbol) }
    attr_reader :name

    # The object to check inclusion against
    #
    # @example
    #   type.includes # => nil
    #
    # @return [Object] the object to check inclusion against
    #
    # @api public
    sig { returns(::Object) }
    attr_reader :includes

    # The options for the T::Struct.prop method
    #
    # @example
    #   type.options # => { default: 'Jon' }
    #
    # @return [Hash{Symbol => Object}] the options for the type
    #
    # @api private
    sig { returns(T::Hash[Symbol, ::Object]) }
    attr_reader :options

    # Initialize the type
    #
    # @param name [Symbol] the name of the type
    # @param includes [Object] the object to check inclusion against
    # @param options [Hash{Symbol => Object}] the options for the type
    #
    # @return [void]
    #
    # @api private
    sig { params(name: Symbol, includes: ::Object, options: ::Object).void }
    def initialize(name, includes: nil, **options)
      @name     = name
      @includes = T.let(includes, T.nilable(::Object))
      @options  = options

      freeze
    end

    # The default value of the type
    #
    # @example
    #   type.default # => 'Jon'
    #
    # @return [Object] the default value of the type
    #
    # @api public
    sig { returns(T.nilable(::Object)) }
    def default
      options[:default]
    end

    # Deep freeze the type
    #
    # @example
    #   type = String.new(:first_name)
    #   type.freeze
    #   type.frozen? # => true
    #
    # @return [Type] the type
    #
    # @api public
    sig { returns(T.self_type) }
    def freeze
      instance_variables.each do |ivar_name|
        T.let(instance_variable_get(ivar_name), ::Object).freeze
      end

      T.let(super(), Type)
    end
  end
end
