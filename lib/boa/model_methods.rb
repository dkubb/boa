# typed: strong
# frozen_string_literal: true

module Boa
  # A module for class methods
  module ModelMethods
    extend T::Sig
    extend T::Helpers

    requires_ancestor { Object }

    abstract!

    # Hook called when the module is included
    #
    # @param descendant [Module] the module or class including this module
    #
    # @return [void]
    #
    # @api private
    sig { params(descendant: Module).void }
    def inherited(descendant)
      descendant.instance_variable_set(:@properties, properties.dup)

      super
    end

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
    #   klass  = Class.new { include Boa }
    #   result = klass.prop :last_name, Boa::Type::String
    #   klass.equal?(result)                               # => true
    #
    # @param name [Symbol] the name of the property
    # @param type [Type] the type of the property
    #
    # @return [ModelMethods] the class method module
    #
    # @api public
    sig { params(name: Symbol, type: T::Class[Type], required: T::Boolean, options: Object).returns(T.self_type) }
    def prop(name, type, required: true, **options)
      properties[name] = type.new(name, required:, **options)
      self
    end

    # Finalize the class methods
    #
    # @example
    #   klass = Class.new { include Boa }
    #   klass.finalize.frozen?             # => true
    #
    # @return [ModelMethods] the class method module
    #
    # @api public
    sig { returns(T.self_type) }
    def finalize
      properties.each_value do |type|
        type.add_methods(T.bind(self, Module)).finalize
      end

      freeze
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
