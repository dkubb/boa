# typed: strong
# frozen_string_literal: true

require 'test_helper'

require_relative '../boa_test'

module Boa
  class Test
    class Util < Minitest::Test
      extend MutantCoverage
      extend T::Sig

      cover 'Boa::Util.normalize_integer_range'

      parallelize_me!

      sig { returns(T.class_of(Boa::Util)) }
      def described_class
        Boa::Util
      end

      sig { void }
      def test_normalize_integer_range
        assert_normalize_integer_range(nil..,  nil..)
        assert_normalize_integer_range(..10,   ..10)
        assert_normalize_integer_range(...10,  ..9)
        assert_normalize_integer_range(1..,    1..)
        assert_normalize_integer_range(1...,   1..)
        assert_normalize_integer_range(1..10,  1..10)
        assert_normalize_integer_range(1...10, 1..9)
      end

    private

      sig { params(input: T::Range[T.nilable(::Integer)], expected: T::Range[T.nilable(::Integer)]).void }
      def assert_normalize_integer_range(input, expected)
        assert_equal(expected, described_class.normalize_integer_range(input))
      end
    end
  end
end
