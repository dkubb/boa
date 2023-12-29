# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # A boolean type
    class Boolean < self
      # The default includes for the boolean type
      DEFAULT_INCLUDES = T.let([true, false].freeze, T::Array[T::Boolean])
      private_constant(:DEFAULT_INCLUDES)

      class_type(T::Boolean)

      # Initialize the boolean type
      #
      # @example
      #   type = Boolean.new(:admin?)
      #   type.class  # => Boolean
      #   type.name   # => :admin?
      #
      # @param _name [Symbol] the name of the type
      # @param includes [Enumerable<Boolean>] the object to check inclusion against
      # @param options [Hash] the options to initialize with
      #
      # @return [void]
      #
      # @api public
      sig { params(_name: Symbol, includes: T::Array[T::Boolean], options: ::Object).void }
      def initialize(_name, includes: DEFAULT_INCLUDES, **options)
        super
      end
    end
  end
end
