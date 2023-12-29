# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # A string type
    class String < self
      # The type for the string length constraint
      LengthType = T.type_alias { T::Range[T.nilable(::Integer)] }
      private_constant(:LengthType)

      # The default length for the string type
      DEFAULT_LENGTH = T.let(Range.new(0, nil).freeze, LengthType)
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
      sig { returns(LengthType) }
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
      # @param includes [Enumerable<Integer>, nil] the object to check inclusion against
      # @param length [Range<::Integer>] the length of the string
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [Type::String] the string type
      #
      # @raise [ArgumentError] if the length constraint is invalid
      #
      # @api public
      sig { params(name: Symbol, includes: T.nilable(Includes), length: LengthType, options: ::Object).returns(T.attached_class) }
      def self.new(name, includes: nil, length: DEFAULT_LENGTH, **options)
        super(name, **options, includes:, length: parse_length(length).unwrap)
      end

      # Parse the length constraint
      #
      # @param length [Range<::Integer>] the length constraint
      #
      # @return [Result<LengthType, ArgumentError>] the result of parsing the length constraint
      #
      # @api private
      sig { params(length: LengthType).returns(Result[LengthType, ExceptionType]) }
      def self.parse_length(length) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Metrics/MethodLength
        normalized = Util.normalize_integer_range(length)

        min, max = normalized.begin || 0, normalized.end

        Result.parse(T.let(min..max, LengthType)) do
          if min.negative?
            "length.begin must be greater than or equal to 0, but was #{min}"
          elsif max&.negative?
            "length.end must be greater than or equal to 0 or nil, but was #{max}"
          elsif max && max < min # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Style/MissingElse
            "length range cannot be empty, but was: #{length}"
          end
        end
      end
      private_class_method(:parse_length)

      # Initialize the string type
      #
      # @param name [Symbol] the name of the type
      # @param includes [Enumerable<Integer>, nil] the object to check inclusion against
      # @param length [Range<::Integer>] the length of the string
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [void]
      #
      # @api private
      sig { params(name: Symbol, includes: T.nilable(Includes), length: LengthType, options: ::Object).void }
      def initialize(name, includes: nil, length: DEFAULT_LENGTH, **options)
        @length = T.let(length, LengthType)

        super(name, **options, includes:)
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
