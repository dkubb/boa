# typed: strong
# frozen_string_literal: true

module Boa
  # A collection of utility methods
  module Util
    extend T::Sig

    DEFAULT_RANGE = T.let(nil.., T::Range[T.nilable(::Integer)])
    private_constant(:DEFAULT_RANGE)

    # Normalize an integer range
    #
    # @param range [Range<::Integer>] an integer range
    # @param default [Range<::Integer>] the default integer range
    #
    # @return [Range<::Integer>] the normalized integer range
    #
    # @api private
    sig do
      params(
        range:   T::Range[T.nilable(::Integer)],
        default: T::Range[T.nilable(::Integer)]
      ).returns(T::Range[T.nilable(::Integer)])
    end
    def self.normalize_integer_range(range, default: DEFAULT_RANGE)
      base       = default.equal?(DEFAULT_RANGE) ? default : normalize_integer_range(default)
      range_end  = range.end
      range_end -= 1 if range_end && range.exclude_end?

      Range.new(range.begin || base.begin, range_end || base.end)
    end
  end
end
