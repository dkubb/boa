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
        min_length, max_length = minmax_length(length)

        assert_valid_length(min_length, max_length)

        super(name, length: min_length..max_length, **options)
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

      # Assert the length constraint is valid
      #
      # @param min [::Integer] the minimum length
      # @param max [::Integer, nil] the maximum length
      #
      # @return [void]
      #
      # @raise [ArgumentError] if the length constraint is invalid
      #
      # @api private
      sig { params(min: ::Integer, max: T.nilable(::Integer)).void }
      def self.assert_valid_length(min, max)
        message =
          if min.negative?
            "length.begin must be greater than or equal to 0, but was #{min}"
          elsif max&.negative?
            "length.end must be greater than or equal to 0 or nil, but was #{max}"
          elsif max&.<(min) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Style/MissingElse
            "length.end must be greater than or equal to length.begin, but was: #{min..max} (normalized)"
          end

        raise(ArgumentError, message) if message
      end

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
