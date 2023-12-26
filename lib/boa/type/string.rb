# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # A string type
    class String < self
      # The default length for the string type
      DEFAULT_LENGTH = T.let(Range.new(0, nil).freeze, T::Range[T.nilable(::Integer)])
      private_constant(:DEFAULT_LENGTH)

      class_type(::String)

      # The length of the string
      #
      # @example
      #   type.length  # => 0..
      #
      # @return [Range<::Integer>] the length of the string
      #
      # @api public
      sig { returns(T::Range[T.nilable(::Integer)]) }
      attr_reader :length

      # Construct the string type
      #
      # @example with the default length
      #   type = String.new(:name)
      #   type.class   # => String
      #   type.name    # => :name
      #   type.length  # => 0..
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
      #   type.length  # => 0..
      #   type.default # => 'Dan Kubb'
      #
      # @example with a nil minimum length
      #   type = String.new(:name, length: ..50, default: 'Dan Kubb')
      #   type.class   # => String
      #   type.name    # => :name
      #   type.length  # => 0..50
      #   type.default # => 'Dan Kubb'
      #
      # @param name [Symbol] the name of the type
      # @param length [Range<::Integer>] the length of the string
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [Type::String] the string type
      #
      # @raise [ArgumentError] if the length constraint is invalid
      #
      # @api public
      sig { params(name: Symbol, length: T::Range[T.nilable(::Integer)], options: ::Object).returns(T.attached_class) }
      def self.new(name, length: DEFAULT_LENGTH, **options)
        min, max = minmax_length(length)

        raise(ArgumentError, "length.begin must be greater than or equal to 0, but was #{min}")              if min.negative?
        raise(ArgumentError, "length.end must be greater than or equal to 0 or nil, but was #{max}")         if max&.negative?
        raise(ArgumentError, "length.end must be greater than or equal to length.begin, but was: #{length}") if max&.<(min)

        super(name, length: min..max, **options)
      end

      # The min and max from the length constraint
      #
      # @param length [Range<::Integer>] the length constraint of the string
      #
      # @return [Array(::Integer, ::Integer), Array(::Integer, nil)] the min, max length constraints
      #
      # @api private
      sig { params(length: T::Range[T.nilable(::Integer)]).returns([::Integer, T.nilable(::Integer)]) }
      def self.minmax_length(length)
        normalized = Util.normalize_integer_range(length)

        [normalized.begin || 0, normalized.end]
      end
      private_class_method(:minmax_length)

      # Initialize the string type
      #
      # @param name [Symbol] the name of the type
      # @param length [Range<::Integer>] the length of the string
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [void]
      #
      # @api private
      sig { params(name: Symbol, length: T::Range[T.nilable(::Integer)], options: ::Object).void }
      def initialize(name, length: DEFAULT_LENGTH, **options)
        @length = T.let(length, T::Range[T.nilable(::Integer)])

        super(name, **options)
      end

      # The minimum length of the string
      #
      # @example
      #   type = String.new(:name)
      #   type.min_length  # => 0
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
    end
  end
end
