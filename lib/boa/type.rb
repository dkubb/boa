# typed: strong
# frozen_string_literal: true

module Boa
  # Abstract class for types
  class Type
    extend T::Helpers
    extend T::Sig
    include Equality

    # The base type alias
    Base = T.type_alias { T.untyped } # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Sorbet/ForbidTUntyped
    public_constant(:Base)

    abstract!

    # Lookup the type for a base type
    #
    # @example
    #   Boa::Type[::String]  # => Boa::Type::String
    #
    # @param base_type [Base] the base type
    #
    # @return [Class<Type>] the type for the base type
    #
    # @api public
    sig { overridable.params(base_type: Base).returns(T.class_of(Type)) }
    def self.[](base_type)
      base_types.fetch(base_type, Object)
    end

    # Set the type for a base type
    #
    # @example
    #   Boa::Type[::String] = Boa::Type::String
    #   Boa::Type[::String]  # => Boa::Type::String
    #
    # @param base_type [Base] the base type
    # @param descendant [Class<Type>] the type for the base type
    #
    # @return [Class<Type>] the type for the base type
    #
    # @api public
    sig { overridable.params(base_type: Base, descendant: T.class_of(Type)).returns(T.class_of(Type)) }
    def self.[]=(base_type, descendant)
      base_types[base_type] = descendant
    end

    # The base types
    #
    # @return [Hash{Base => Class<Type>}] the base types
    #
    # @api private
    sig { overridable.returns(T::Hash[Base, T.class_of(Type)]) }
    def self.base_types
      @base_types ||= T.let({}, T.nilable(T::Hash[Base, T.class_of(Type)]))
    end
    private_class_method(:base_types)

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

    # The options for the T::Struct.prop method
    #
    # @example
    #   type.options  # => { default: 'Jon' }
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
    end

    # The default value of the type
    #
    # @example
    #   type.default  # => 'Jon'
    #
    # @return [Object] the default value of the type
    #
    # @api public
    sig { returns(T.nilable(::Object)) }
    def default
      options[:default]
    end
  end
end
