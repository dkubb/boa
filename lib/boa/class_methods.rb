# typed: strong
# frozen_string_literal: true

module Boa
  # A module for class methods
  module ClassMethods
    extend T::Helpers
    extend T::Sig

    requires_ancestor { T.class_of(T::InexactStruct) }

    abstract!

    # The properties for this type
    #
    # @return [Hash{Symbol => Type}] the properties for this type
    #
    # @api private
    sig { returns(T::Hash[Symbol, Type]) }
    def properties
      @properties ||= T.let({}, T.nilable(T::Hash[Symbol, Type]))
    end

    # A DSL method to set up the properties
    #
    # @example
    #   klass  = Class.new(T::Struct) { include Boa }
    #   result = klass.prop :last_name, String
    #   klass.equal?(result) # => true
    #
    # @param name [Symbol] the name of the property
    # @param class_type [Type::ClassType] the type of the property
    # @param options [Hash] the options for the property
    #
    # @return [ClassMethods] the class method module
    #
    # @api public
    sig { params(name: Symbol, class_type: Type::ClassType, options: Object).returns(T.self_type) }
    def prop(name, class_type, **options)
      property = properties[name] = Type[class_type].new(name, **options)
      super(name, class_type, **property.options)
      self
    end

    # Deep freeze the class state
    #
    # @example
    #   klass = Class.new { include Boa }
    #   klass.freeze
    #   klass.frozen? # => true
    #
    # @return [ClassMethods] the class method module
    #
    # @api public
    sig { returns(T.self_type) }
    def freeze
      instance_variables.each do |ivar_name|
        T.let(instance_variable_get(ivar_name), Object).freeze
      end

      T.let(super(), ClassMethods)
    end
  end
end
