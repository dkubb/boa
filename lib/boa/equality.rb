# typed: strong
# frozen_string_literal: true

module Boa
  # A module for comparing objects for equality
  module Equality
    extend T::Sig
    extend T::Helpers

    requires_ancestor { Object }

    abstract!

    # Compare the object with other object for equivalency
    #
    # @example when the objects are equal
    #   equality_object == equality_object  # => true
    #
    # @example when the objects are not equal
    #   equality_object == other  # => false
    #
    # @param [Equality] other
    #   the other object to compare with
    #
    # @return [Boolean]
    #
    # @api public
    sig { params(other: Equality).returns(T::Boolean) }
    def ==(other)
      other.is_a?(self.class) && object_state == other.object_state
    end

    # Compare the object with other object for equality
    #
    # @example when the objects are equal
    #   equality_object.eql?(equality_object)  # => true
    #
    # @example when the objects are not equal
    #   equality_object.eql?(other)  # => false
    #
    # @param [Equality] other
    #   the other object to compare with
    #
    # @return [Boolean]
    #
    # @api public
    sig { params(other: Equality).returns(T::Boolean) }
    def eql?(other)
      return false unless other.instance_of?(self.class)

      T.let(object_state.eql?(other.object_state), T::Boolean)
    end

    # The hash value of the object
    #
    # @example
    #   equality_object.hash.class  # => Integer
    #
    # @return [Integer] the hash value of the object
    #
    # @api public
    sig { returns(Integer) }
    def hash
      self.class.hash ^ T.let(object_state.hash, Integer)
    end

  protected

    # The state of the object
    #
    # @return [Hash{Symbol => Object}] the state of the object
    #
    # @api private
    sig { overridable.returns(T::Hash[Symbol, Object]) }
    def object_state
      instance_variables.to_h do |ivar_name|
        [ivar_name, instance_variable_get(ivar_name)]
      end
    end
  end
end
