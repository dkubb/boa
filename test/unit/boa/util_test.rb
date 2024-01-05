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
        PropCheck.forall(integer_range_generator) do |range|
          range      = T.let(range, T::Range[T.nilable(Integer)])
          normalized = described_class.normalize_integer_range(range)

          if range.exclude_end?
            refute_equal(range,          normalized)
            assert_same(range.begin,     normalized.begin)
            assert_same(range.end&.pred, normalized.end)
            refute_predicate(normalized, :exclude_end?)
          else
            assert_same(normalized, range)
          end
        end
      end

    private

      sig { returns(PropCheck::Generator) }
      def integer_range_generator
        tuple_generator =
          T.let(
            G.tuple(
              G.nillable(G.integer),
              G.nillable(G.integer),
              G.boolean
            ),
            PropCheck::Generator
          )

        range_generator =
          tuple_generator.bind do |range_begin, range_end, range_exclusive|
            range_begin     = T.let(range_begin,     T.nilable(Integer))
            range_end       = T.let(range_end,       T.nilable(Integer))
            range_exclusive = T.let(range_exclusive, T::Boolean)

            G.constant(Range.new(range_begin, range_end, range_exclusive))
          end

        T.let(range_generator, PropCheck::Generator)
      end
    end
  end
end
