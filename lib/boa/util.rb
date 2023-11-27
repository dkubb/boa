# typed: strong
# frozen_string_literal: true

module Boa
  # A collection of utility methods
  module Util
    extend T::Sig

    # Normalize an integer range
    #
    # @param range [Range<::Integer>] an integer range
    #
    # @return [Range<::Integer>] the normalized integer range
    #
    # @api private
    sig { params(range: T::Range[T.nilable(::Integer)]).returns(T::Range[T.nilable(::Integer)]) }
    def self.normalize_integer_range(range)
      range_end  = range.end
      range_end -= 1 if range_end && range.exclude_end?

      Range.new(range.begin || 0, range_end)
    end
  end
end
