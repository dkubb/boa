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
      if range.exclude_end?
        range.begin..range.end&.pred
      else
        range
      end
    end
  end
end
