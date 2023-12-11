# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # An integer type
    class Integer < self
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

      # Initialize the integer type
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
      # @api public
      sig { params(name: Symbol, range: T::Range[T.nilable(::Integer)], options: ::Object).void }
      def initialize(name, range: Range.new(nil, nil), **options)
        @range = T.let(Util.normalize_integer_range(range), T::Range[T.nilable(::Integer)])

        super(name, **options)
      end

      # The minimum range of the integer
      #
      # @example with no minimum range
      #   type = Integer.new(:age)
      #   type.min_range  # => nil

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
