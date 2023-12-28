# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # An integer type
    class Integer < self
      # The default range for the integer type
      DEFAULT_RANGE = T.let(Range.new(nil, nil).freeze, T::Range[T.nilable(::Integer)])
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
      sig { returns(T::Range[T.nilable(::Integer)]) }
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
      sig { params(name: Symbol, range: T::Range[T.nilable(::Integer)], options: ::Object).returns(T.attached_class) }
      def self.new(name, range: DEFAULT_RANGE, **options)
        range = Util.normalize_integer_range(range)

        assert_valid_range(range.begin, range.end)

        super(name, range:, **options)
      end

      # Assert the range constraint is valid
      #
      # @param min [::Integer, nil] the minimum range
      # @param max [::Integer, nil] the maximum range
      #
      # @return [void]
      #
      # @raise [ArgumentError] if the range constraint is invalid
      #
      # @api private
      sig { params(min: T.nilable(::Integer), max: T.nilable(::Integer)).void }
      def self.assert_valid_range(min, max)
        return if min.nil? || max.nil? || max >= min

        raise(ArgumentError, "range.end must be greater than or equal to range.begin, but was: #{min..max} (normalized)")
      end
      private_class_method(:assert_valid_range)

      # Initialize the integer type
      #
      # @param name [Symbol] the name of the type
      # @param range [Range<::Integer>] the range of the integer
      # @param options [Hash{Symbol => Object}] the options for the type
      #
      # @return [void]
      #
      # @api private
      sig { params(name: Symbol, range: T::Range[T.nilable(::Integer)], options: ::Object).void }
      def initialize(name, range: DEFAULT_RANGE, **options)
        @range = T.let(range, T::Range[T.nilable(::Integer)])

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
