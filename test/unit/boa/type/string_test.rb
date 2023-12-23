# typed: strong
# frozen_string_literal: true

require 'test_helper'

require_relative '../type_test'

module Boa
  class Test
    class Type
      class String < Minitest::Test
        extend T::Sig
        include Support::InstanceMethodsBehaviour::Setup
        include Support::TypeBehaviour::Setup

        parallelize_me!

        sig { override.returns(T.class_of(Boa::Type::String)) }
        def described_class
          Boa::Type::String
        end

        sig { override.returns(Boa::Type::String) }
        def state_inequality
          @state_inequality ||= T.let(described_class.new(:inequal), T.nilable(Boa::Type::String))
        end

        sig { override.params(klass: T::Class[Boa::InstanceMethods]).returns(Boa::Type::String) }
        def new_object(klass)
          raise(ArgumentError, "klass must be a Boa::Type::String, but was #{klass}") unless klass <= Boa::Type::String

          klass.new(type_name, **options)
        end

        sig { void }
        def test_class_hierarchy
          assert_operator(Boa::Type, :>, described_class)
          assert_equal(Boa::Type::String, described_class)
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

          cover('Boa::Type::String#initialize')

          sig { override.returns(::String) }
          def non_nil_default
            @non_nil_default ||= T.let('Jon', T.nilable(::String))
          end

          sig { override.returns(NilClass) }
          def default_includes; end

          sig { void }
          def test_with_no_length_option
            subject = described_class.new(type_name)

            assert_equal(type_name, subject.name)
            assert_equal(0.., subject.length)
            assert_equal(0, subject.min_length)
            assert_nil(subject.max_length)
            assert_operator(subject, :frozen?)
          end

          sig { void }
          def test_with_length_option
            subject = described_class.new(type_name, length: 2...10)

            assert_equal(type_name, subject.name)
            assert_equal(2..9, subject.length)
            assert_equal(2, subject.min_length)
            assert_equal(9, subject.max_length)
            assert_operator(subject, :frozen?)
          end

          sig { void }
          def test_with_length_option_and_nil_minimum_length
            subject = described_class.new(type_name, length: ..10)

            assert_equal(type_name, subject.name)
            assert_equal(0..10, subject.length)
            assert_equal(0, subject.min_length)
            assert_equal(10, subject.max_length)
            assert_operator(subject, :frozen?)
          end
        end

        class Name < self
          include Support::TypeBehaviour::Name
        end

        class Includes < self
          include Support::TypeBehaviour::Includes

          sig { override.returns(T::Array[::String]) }
          def includes
            @includes ||= T.let(%w[test], T.nilable(T::Array[::String]))
          end
        end

        class Options < self
          include Support::TypeBehaviour::Options
        end

        class Default < self
          include Support::TypeBehaviour::Default

          sig { override.returns(::String) }
          def default
            'test'
          end
        end

        class MinLength < self
          extend MutantCoverage

          cover('Boa::Type::String#min_length')

          sig { void }
          def test_with_no_length
            subject = described_class.new(type_name)

            assert_same(0, subject.min_length)
          end

          sig { void }
          def test_with_length_and_minimum_length
            subject = described_class.new(type_name, length: 2..10)

            assert_same(2, subject.min_length)
          end
        end

        class MaxLength < self
          extend MutantCoverage

          cover('Boa::Type::String#max_length')

          sig { void }
          def test_with_no_length
            subject = described_class.new(type_name)

            assert_nil(subject.max_length)
          end

          sig { void }
          def test_with_inclusive_length_and_no_maximum_length
            subject = described_class.new(type_name, length: 2..)

            assert_nil(subject.max_length)
          end

          sig { void }
          def test_with_inclusive_length_and_maximum_length
            subject = described_class.new(type_name, length: 2..10)

            assert_same(10, subject.max_length)
          end

          sig { void }
          def test_with_exclusive_length_and_no_maximum_length
            subject = described_class.new(type_name, length: 2...)

            assert_nil(subject.max_length)
          end

          sig { void }
          def test_with_exclusive_length_and_maximum_length
            subject = described_class.new(type_name, length: 2...10)

            assert_same(9, subject.max_length)
          end
        end

        class Freeze < self
          include Support::TypeBehaviour::Freeze
        end

        class InstanceMethods < self
          include Support::InstanceMethodsBehaviour::InstanceMethods
        end

        class Eql < self
          include Support::InstanceMethodsBehaviour::Eql
        end

        class Hash < self
          include Support::InstanceMethodsBehaviour::Hash
        end
      end
    end
  end
end
