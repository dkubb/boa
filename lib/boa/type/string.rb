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
      sig { returns(T::Range[T.nilable(::Integer)]) }
      attr_reader :length

      # Initialize the string type
      #
      # @example with the default length
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
      #   type = String.new(:name, length: ..50, default: 'Dan Kubb')
      #   type.class   # => String
      #   type.name    # => :name
      #   type.length  # => 1..50
      #   type.default # => 'Dan Kubb'
      #
      # @param name [Symbol] the name of the type
      # @param length [Range<::Integer>] the length of the string
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [void]
      #
      # @api public
      sig { params(name: Symbol, length: T::Range[T.nilable(::Integer)], options: ::Object).void }
      def initialize(name, length: 1.., **options)
        @length = T.let(normalize_integer_range(length), T::Range[T.nilable(::Integer)])

        super(name, **options)
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
        T.must(length.begin)
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
        length.end
      end

    private

      # Normalize an integer range
      #
      # @param range [Range<::Integer>] an integer range
      #
      # @return [Range<::Integer>] the normalized integer range
      #
      # @api private
      sig { params(range: T::Range[T.nilable(::Integer)]).returns(T::Range[T.nilable(::Integer)]) }
      def normalize_integer_range(range)
        range_end  = range.end
        range_end -= 1 if range_end && range.exclude_end?

        Range.new(range.begin || 1, range_end)
      end
    end
  end
end
