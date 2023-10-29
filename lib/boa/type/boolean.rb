# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # A boolean type
    class Boolean < Object
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

      private

      # Add reader methods to the descendant
      #
      # @example
      #   descendant.new.respond_to?(:author?)  # => false
      #   type.add_methods(descendant)          # => type
      #   descendant.new.respond_to?(:author?)  # => true
      #
      # @param descendant [ClassMethods] the class to add methods to
      #
      # @return [Type] the type
      #
      # @api private
      sig { params(descendant: Module).returns(T.self_type) }
      def add_reader(descendant)
        name = name()
        descendant.define_method(:"#{name}?") do
          boolean = T.let(public_send(name), T.nilable(T::Boolean))
          boolean.equal?(true)
        end

        super
      end
    end
  end
end
