# typed: strong
# frozen_string_literal: true

require 'test_helper'

require_relative '../type_test'

module Boa
  class Test
    class Type
      class Integer < Minitest::Test
        extend T::Sig
        include Support::InstanceMethodsBehaviour::Setup
        include Support::TypeBehaviour::Setup

        parallelize_me!

        sig { override.returns(T.class_of(Boa::Type::Integer)) }
        def described_class
          Boa::Type::Integer
        end

        sig { override.returns(Boa::Type::Integer) }
        def state_inequality
          @state_inequality ||= T.let(described_class.new(:inequal), T.nilable(Boa::Type::Integer))
        end

        sig { override.params(klass: T::Class[Boa::InstanceMethods]).returns(Boa::Type::Integer) }
        def new_object(klass)
          raise(ArgumentError, "klass must be a Boa::Type::Integer, but was #{klass}") unless klass <= Boa::Type::Integer

          klass.new(type_name, **options)
        end

        sig { void }
        def test_class_hierarchy
          assert_operator(Boa::Type, :>, described_class)
          assert_equal(Boa::Type::Integer, described_class)
        end

        class ElementReference < self
          include Support::TypeBehaviour::ElementReference
        end

        class ElementAssignment < self
          include Support::TypeBehaviour::ElementAssignment
        end

        class ClassType < self
          include Support::TypeBehaviour::ClassType
        end

        class Inherited < self
          include Support::TypeBehaviour::Inherited
        end

        class New < self
          extend MutantCoverage
          include Support::TypeBehaviour::New

          cover('Boa::Type::Integer#initialize')

          sig { override.returns(::Integer) }
          def non_nil_default
            0
          end

          sig { override.returns(NilClass) }
          def default_includes; end

          sig { void }
          def test_with_no_range_option
            subject = described_class.new(type_name)

            assert_same(type_name, subject.name)
            assert_equal(nil.., subject.range)
            assert_operator(subject, :frozen?)
          end

          sig { void }
          def test_with_range_option_and_minimum_range
            subject = described_class.new(type_name, range: 0..10)

            assert_same(type_name, subject.name)
            assert_equal(0..10, subject.range)
            assert_operator(subject, :frozen?)
          end

          sig { void }
          def test_with_range_option_and_nil_minimum_range
            subject = described_class.new(type_name, range: ..10)

            assert_same(type_name, subject.name)
            assert_equal(..10, subject.range)
            assert_operator(subject, :frozen?)
          end

          sig { void }
          def test_with_range_option_and_singleton_range
            subject = described_class.new(type_name, range: 1..1)

            assert_same(type_name, subject.name)
            assert_equal(1..1, subject.range)
            assert_operator(subject, :frozen?)
          end

          sig { void }
          def test_with_range_option_and_empty_range
            exception = T.let(
              assert_raises(ArgumentError) { described_class.new(type_name, range: 1...1) },
              ArgumentError
            )

            assert_equal('range cannot be empty, but was: 1...1', exception.message)
          end
        end

        class Name < self
          include Support::TypeBehaviour::Name
        end

        class Includes < self
          include Support::TypeBehaviour::Includes

          sig { override.returns(T::Array[::Integer]) }
          def includes
            @includes ||= T.let([1].freeze, T.nilable(T::Array[::Integer]))
          end
        end

        class Options < self
          include Support::TypeBehaviour::Options
        end

        class Default < self
          include Support::TypeBehaviour::Default

          sig { override.returns(::Integer) }
          def default
            0
          end
        end

        class MinRange < self
          extend MutantCoverage

          cover('Boa::Type::Integer#min_range')

          sig { void }
          def test_with_no_range_option
            subject = described_class.new(type_name)

            assert_nil(subject.min_range)
          end

          sig { void }
          def test_with_range_option_and_no_minimum_range
            subject = described_class.new(type_name, range: ..100)

            assert_nil(subject.min_range)
          end

          sig { void }
          def test_with_range_option_and_minimum_range
            subject = described_class.new(type_name, range: 1..100)

            assert_same(1, subject.min_range)
          end
        end

        class MaxRange < self
          extend MutantCoverage

          cover('Boa::Type::Integer#max_range')

          sig { void }
          def test_with_no_range_option
            subject = described_class.new(type_name)

            assert_nil(subject.max_range)
          end

          sig { void }
          def test_with_inclusive_range_option_and_no_maximum_range
            subject = described_class.new(type_name, range: 1..)

            assert_nil(subject.max_range)
          end

          sig { void }
          def test_with_inclusive_range_option_and_maximum_range
            subject = described_class.new(type_name, range: 1..100)

            assert_same(100, subject.max_range)
          end

          sig { void }
          def test_with_exclusive_range_option_and_no_maximum_range
            subject = described_class.new(type_name, range: 1...)

            assert_nil(subject.max_range)
          end

          sig { void }
          def test_with_exclusive_range_option_and_maximum_range
            subject = described_class.new(type_name, range: 1...100)

            assert_same(99, subject.max_range)
          end
        end

        class Freeze < self
          include Support::TypeBehaviour::Freeze
        end

        class Parse < self
          extend MutantCoverage
          include Support::TypeBehaviour::Parse

          cover('Boa::Type::Integer#parse')

          sig { override.returns(::Integer) }
          def valid_value
            1
          end

          sig { override.returns(::Integer) }
          def invalid_value
            0
          end

          sig { void }
          def test_with_no_range_option
            subject = described_class.new(type_name)

            assert_equal(Boa::Success.new(0), subject.parse(0))
          end

          sig { void }
          def test_with_range_option_and_minimum_range
            subject = described_class.new(type_name, range: 1..)

            assert_equal(Boa::Success.new(1), subject.parse(1))
          end

          sig { void }
          def test_with_range_option_and_minimum_range_and_invalid_value
            subject = described_class.new(type_name, range: 1..)

            assert_equal(Boa::Failure.new('must be within 1.., but was: 0'), subject.parse(0))
          end

          sig { void }
          def test_with_range_option_and_maximum_range
            subject = described_class.new(type_name, range: ..1)

            assert_equal(Boa::Success.new(1), subject.parse(1))
          end

          sig { void }
          def test_with_range_option_and_maximum_range_and_invalid_value
            subject = described_class.new(type_name, range: ..1)

            assert_equal(Boa::Failure.new('must be within ..1, but was: 2'), subject.parse(2))
          end

          sig { void }
          def test_with_invalid_type
            subject = described_class.new(type_name)

            assert_equal(Boa::Failure.new('must be an Integer, but was: String'), subject.parse('0'))
          end
        end

        class Equality < self
          include Support::InstanceMethodsBehaviour::Equality
        end

        class Eql < self
          include Support::InstanceMethodsBehaviour::Eql
        end

        class Hash < self
          include Support::InstanceMethodsBehaviour::Hash
        end

        class DeconstructKeys < self
          include Support::InstanceMethodsBehaviour::DeconstructKeys

          sig { override.returns(T::Hash[Symbol, ::Object]) }
          def expected_object_state
            { range: nil.., name: type_name, includes: nil, options: {} }
          end
        end

        class Deconstruct < self
          include Support::InstanceMethodsBehaviour::Deconstruct

          sig { override.returns(T::Hash[Symbol, ::Object]) }
          def expected_object_state
            { range: nil.., name: type_name, includes: nil, options: {} }
          end
        end
      end
    end
  end
end
