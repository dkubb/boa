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
      # @param range [Range<::Integer>] the range of the integer
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [void]
      #
      # @raise [ArgumentError] if the range constraint is invalid
      #
      # @api public
      sig { params(name: Symbol, range: RangeType, options: ::Object).returns(T.attached_class) }
      def self.new(name, range: DEFAULT_RANGE, **options)
        super(name, range: parse_range(range).unwrap, **options)
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
      # @param range [Range<::Integer>] the range of the integer
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [void]
      #
      # @api private
      sig { params(name: Symbol, range: RangeType, options: ::Object).void }
      def initialize(name, range: DEFAULT_RANGE, **options)
        @range = T.let(range, RangeType)

        super(name, **options)
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
    end
  end
end
