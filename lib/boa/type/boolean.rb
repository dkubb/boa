# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # A boolean type
    class Boolean < self
      Type[T::Boolean] = self

      # Initialize the boolean type
      #
      # @example
      #   type = Boolean.new(:admin?)
      #   type.class  # => Boolean
      #   type.name   # => :admin?
      #
      # @param _name [Symbol] the name of the type
      # @param includes [Array<Boolean>] the object to check inclusion against
      # @param options [Hash] the options to initialize with
      #
      # @return [void]
      #
      # @api public
      sig { params(_name: Symbol, includes: T::Array[T::Boolean], options: ::Object).void }
      def initialize(_name, includes: [true, false], **options)
        super
      end
    end
  end
end
