# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # An integer type
    class Integer < self
      # The type for the range integer constraint
      RangeType = T.type_alias { T::Range[T.nilable(::Integer)] }
      private_constant(:RangeType)

      # The default range for the integer type
      DEFAULT_RANGE = T.let(Range.new(nil, nil).freeze, RangeType)
      private_constant(:DEFAULT_RANGE)

      class_type(::Integer)

      # The range of the integer
      #
      # @example
      #   type = Integer.new(:age)
      #   type.range  # => nil..
      #
      # @return [Range<::Integer>] the range of the integer
      #
      # @api public
      sig { returns(RangeType) }
      attr_reader :range

      # Constructs the integer type
      #
      # @example with the default range
      #   type = Integer.new(:age)
      #   type.class   # => Integer
      #   type.name    # => :age
      #   type.range   # => nil..
      #   type.default # => nil
      #
      # @example with a custom range
      #   type = Integer.new(:age, range: 0..125)
      #   type.class   # => Integer
      #   type.name    # => :age
      #   type.range   # => 0..125
      #   type.default # => nil
      #
      # @param name [Symbol] the name of the type
      # @param includes [Enumerable<Integer>, nil] the object to check inclusion against
      # @param range [Range<::Integer>] the range of the integer
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [void]
      #
      # @raise [ArgumentError] if the range constraint is invalid
      #
      # @api public
      sig { params(name: Symbol, includes: T.nilable(Includes), range: RangeType, options: ::Object).returns(T.attached_class) }
      def self.new(name, includes: nil, range: DEFAULT_RANGE, **options)
        super(name, **options, includes:, range: parse_range(range).unwrap)
      end

      # Parse the range constraint
      #
      # @param range [RangeType] the range constraint
      #
      # @return [Result<RangeType, ArgumentError>] the result of parsing the range constraint
      #
      # @api private
      sig { params(range: RangeType).returns(Result[RangeType, ExceptionType]) }
      def self.parse_range(range)
        normalized = Util.normalize_integer_range(range)

        Result.parse(normalized) do
          min, max = normalized.begin, normalized.end

          "range cannot be empty, but was: #{range}" if min && max && max < min
        end
      end
      private_class_method(:parse_range)

      # Initialize the integer type
      #
      # @param name [Symbol] the name of the type
      # @param includes [Enumerable<Integer>, nil] the object to check inclusion against
      # @param range [Range<::Integer>] the range of the integer
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [void]
      #
      # @api private
      sig { params(name: Symbol, includes: T.nilable(Includes), range: RangeType, options: ::Object).void }
      def initialize(name, includes: nil, range: DEFAULT_RANGE, **options)
        @range = T.let(range, RangeType)

        super(name, **options, includes:)
      end

      # The minimum range of the integer
      #
      # @example with no minimum range
      #   type = Integer.new(:age)
      #   type.min_range  # => nil
      #
      # @example with a minimum range
      #   type = Integer.new(:age, range: 1..125)
      #   type.min_range  # => 1
      #
      # @return [::Integer, nil] the minimum range of the integer
      #
      # @api public
      sig { returns(T.nilable(::Integer)) }
      def min_range
        range.begin
      end

      # The maximum range of the integer
      #
      # @example with no maximum range
      #   type = Integer.new(:age)
      #   type.max_range  # => nil
      #
      # @example with a maximum range
      #   type = Integer.new(:age, range: 1..125)
      #   type.max_range  # => 125
      #
      # @return [::Integer, nil] the maximum range of the integer
      #
      # @api public
      sig { returns(T.nilable(::Integer)) }
      def max_range
        range.end
      end

      # Parse the integer value
      #
      # @example with a value within range
      #   type = Integer.new(:age, range: 1..125)
      #   type.parse(1)   # => Boa::Success.new(1)
      #   type.parse(125) # => Boa::Success.new(125)
      #
      # @example with a value outside of range
      #   type = Integer.new(:age, range: 1..125)
      #   type.parse(0)   # => Boa::Failure.new('must be within 1..125, but was: 0')
      #   type.parse(126) # => Boa::Failure.new('must be within 1..125, but was: 126')
      #
      # @example with a non-integer value
      #   type = Integer.new(:age)
      #   type.parse('1') # => Boa::Failure.new('must be an Integer, but was: String')
      #
      # @param _value [::Integer] the value to parse
      #
      # @return [Result<::Integer, ExceptionType>] the result of parsing the value
      #
      # @api public
      sig { override.params(_value: ::Object).returns(Result[::Integer, ExceptionType]) }
      def parse(_value) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Metrics/MethodLength
        super.and_then do |value|
          case value
          when ::Integer
            if range.cover?(value)
              Success.new(value)
            else
              Failure.new("must be within #{range}, but was: #{value}")
            end
          else
            Failure.new("must be an Integer, but was: #{T.let(value, ::Object).class}")
          end
        end
      end
    end
  end
end
