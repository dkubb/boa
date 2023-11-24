# typed: strong
# frozen_string_literal: true

module Boa
  # A module for class methods
  module ModelMethods
    extend T::Sig
    extend T::Helpers

    requires_ancestor { T.class_of(T::Struct) }

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
    #   klass.equal?(result)                    # => true
    #
    # @param name [Symbol] the name of the property
    # @param base_type [Class] the type of the property
    # @param options [Hash] the options for the property
    #
    # @return [ModelMethods] the class method module
    #
    # @api public
    sig { params(name: Symbol, base_type: Type::Base, options: Object).returns(T.self_type) }
    def prop(name, base_type, **options)
      property = properties[name] = Type[base_type].new(name, **options)
      super(name, base_type, **property.prop_options)
      self
    end

    # Deep freeze the class state
    #
    # @example
    #   klass = Class.new { include Boa }
    #   klass.freeze
    #   klass.frozen? # => true
    #
    # @return [ModelMethods] the class method module
    #
    # @api public
    sig { returns(T.self_type) }
    def freeze
      properties.each_value(&:freeze)

      instance_variables.each do |ivar_name|
        T.let(instance_variable_get(ivar_name), Object).freeze
      end

      T.let(super(), ModelMethods)
    end
  end
end