# typed: strong
# frozen_string_literal: true

module Boa
  # A module for instance methods
  module InstanceMethods
    extend T::Helpers
    extend T::Sig

    requires_ancestor { Object }

    abstract!

    # Compare the object with other object for equivalency
    #
    # @example when the objects are equal
    #   instance == instance # => true
    #
    # @example when the objects are not equal
    #   instance == other # => false
    #
    # @param [BasicObject] other
    #   the other object to compare with
    #
    # @return [Boolean]
    #
    # @api public
    sig { params(other: T.anything).returns(T::Boolean) }
    def ==(other)
      case other
      when InstanceMethods
        other.is_a?(self.class) && cmp?(other, :==)
      else
        false
      end
    end

    # Compare the object with other object for equality
    #
    # @example when the objects are equal
    #   instance.eql?(instance) # => true
    #
    # @example when the objects are not equal
    #   instance.eql?(other) # => false
    #
    # @param [BasicObject] other
    #   the other object to compare with
    #
    # @return [Boolean]
    #
    # @api public
    sig { params(other: T.anything).returns(T::Boolean) }
    def eql?(other)
      case other
      when InstanceMethods
        other.instance_of?(self.class) && cmp?(other, :eql?)
      else
        false
      end
    end

    # The hash value of the object
    #
    # @example
    #   instance.hash.class # => Integer
    #
    # @return [Integer] the hash value of the object
    #
    # @api public
    sig { returns(Integer) }
    def hash
      self.class.hash ^ T.let(deconstruct_keys(nil).hash, Integer)
    end

    # Deconstruct the object into a hash
    #
    # @example matching specific keys
    #   case instance
    #   in { object_id: }
    #     object_id.class
    #   end # => Integer
    #
    # @example matching all keys
    #   case instance
    #   in **rest
    #      rest.fetch(:object_id).class
    #   end # => Integer
    #
    # @param [Array<Symbol>, nil] keys
    #
    # @return [Hash{Symbol => Object}]
    #
    # @api public
    sig { params(keys: T.nilable(T::Array[Symbol])).returns(T::Hash[Symbol, Object]) }
    def deconstruct_keys(keys)
      (keys.nil? ? prop_names : keys & prop_names).to_h do |key|
        [key, instance_variable_get(:"@#{key}")]
      end
    end

    # Deconstruct the object into an array
    #
    # @example
    #   instance.deconstruct.map(&:class) # => [Integer]
    #
    # @return [Array<Object>] the deconstructed object
    #
    # @api public
    sig { returns(T::Array[Object]) }
    def deconstruct
      prop_names.map { |key| T.let(instance_variable_get(:"@#{key}"), Object) }
    end

  private

    # The names of the properties of the object
    #
    # @return [Array<Symbol>] the names of the properties of the object
    #
    # @api private
    sig { overridable.returns(T::Array[Symbol]) }
    def prop_names
      instance_variables.map { |ivar| T.must(ivar.to_s[1..]).to_sym }
    end

    # Compare the object with other object for equivalency
    #
    # @param [InstanceMethods] other the other object to compare with
    # @param [Symbol] operator the operator to use for comparison
    #
    # @return [Boolean]
    #
    # @api private
    sig { params(other: InstanceMethods, operator: Symbol).returns(T::Boolean) }
    def cmp?(other, operator)
      T.let(deconstruct_keys(nil).public_send(operator, other.deconstruct_keys(nil)), T::Boolean)
    end
  end
end
