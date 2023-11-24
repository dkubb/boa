# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # A string type
    class String < self
      Type[::String] = self

      # The length of the string
      #
      # @example
      #   type.length  # => 1..
      #
      # @return [Range<::Integer>] the length of the string
      #
      # @api public
      sig { returns(T::Range[::Integer]) }
      attr_reader :length

      # Initialize the string type
      #
      # @example with the default length and default
      #   type = String.new(:name)
      #   type.class   # => String
      #   type.name    # => :name
      #   type.length  # => 1..
      #   type.default # => nil
      #
      # @example with a custom length
      #   type = String.new(:name, length: 1..50)
      #   type.class   # => String
      #   type.name    # => :name
      #   type.length  # => 1..50
      #   type.default # => nil
      #
      # @example with a custom default
      #   type = String.new(:name, default: 'Dan Kubb')
      #   type.class   # => String
      #   type.name    # => :name
      #   type.length  # => 1..
      #   type.default # => 'Dan Kubb'
      #
      # @example with a nil minimum length
      #   String.new(:name, length: nil..50)  # => raise ArgumentError, 'length.begin cannot be nil'
      #
      # @param name [Symbol] the name of the type
      # @param length [Range<::Integer>] the length of the string
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [void]
      #
      # @api public
      sig { params(name: Symbol, required: T::Boolean, length: T::Range[::Integer], options: ::Object).void }
      def initialize(name, required: true, length: 1.., **options)
        raise(ArgumentError, 'length.begin cannot be nil') if length.begin.nil?

        @length = T.let(length, T::Range[::Integer])

        super(name, required:, **options)
      end

      # The minimum length of the string
      #
      # @example
      #   type = String.new(:name)
      #   type.min_length  # => 1
      #
      # @return [::Integer] the minimum length of the string
      #
      # @api public
      sig { returns(::Integer) }
      def min_length
        length.begin
      end

      # The maximum length of the string
      #
      # @example with no maximum length
      #   type = String.new(:name)
      #   type.max_length  # => nil
      #
      # @example with a maximum length
      #   type = String.new(:name, length: 1..50)
      #   type.max_length  # => 50
      #
      # @return [::Integer, nil] the maximum length of the string
      #
      # @api public
      sig { returns(T.nilable(::Integer)) }
      def max_length
        max_length = T.assert_type!(length.end, T.nilable(::Integer))
        length.exclude_end? && max_length ? max_length - 1 : max_length
      end
    end
  end
end
