# typed: strong
# frozen_string_literal: true

require 'test_helper'

require_relative '../boa_test'

module Boa
  class Test
    class ClassMethods < Minitest::Test
      extend T::Sig

      parallelize_me!

      class Person < T::InexactStruct
        extend Boa::ClassMethods
      end

      sig { returns(T.class_of(Person)) }
      def described_class
        Person
      end

      sig { returns(Symbol) }
      def type_name
        :name
      end

      class Properties < self
        extend MutantCoverage

        cover 'Boa::ClassMethods#properties'

        sig { void }
        def test_properties
          subject = Class.new(described_class)

          assert_empty(subject.properties)

          type = subject.properties[type_name] = Boa::Type::String.new(type_name)

          assert_equal({ name: type }, subject.properties)
        end
      end

      class Prop < self
        extend MutantCoverage

        cover 'Boa::ClassMethods#properties'

        sig { void }
        def test_prop_sets_the_property
          subject = Class.new(described_class)

          assert_empty(subject.properties)

          subject.prop(type_name, String)

          assert_equal({ name: Boa::Type::String.new(type_name) }, subject.properties)
        end

        sig { void }
        def test_prop_returns_self
          subject = Class.new(described_class)

          assert_same(subject, subject.prop(type_name, String))
        end

        sig { void }
        def test_passes_through_the_options
          subject = Class.new(described_class)

          subject.prop(type_name, String, immutable: true)

          # assert the immutable true option is passed through
          assert_respond_to(subject.new(type_name => 'Test Name'), type_name)
          refute_respond_to(subject.new(type_name => 'Test Name'), :"#{type_name}=")
        end
      end

      class Freeze < self
        extend MutantCoverage

        cover 'Boa::ClassMethods#freeze'

        sig { void }
        def test_freezes_the_instance_variables
          subject = Class.new(described_class)

          ivars(subject).each_value do |value|
            refute_operator(value, :frozen?)
          end

          subject.freeze

          ivars(subject).each_value do |value|
            assert_operator(value, :frozen?)
          end
        end

        sig { void }
        def test_freezes_the_class
          subject = Class.new(described_class)

          assert_operator(subject.freeze, :frozen?)
        end

        sig { void }
        def test_returns_the_class
          subject = Class.new(described_class)

          assert_same(subject, subject.freeze)
        end

      private

        sig { params(object: Object).returns(T::Hash[Symbol, Object]) }
        def ivars(object)
          object.instance_variables.to_h do |ivar|
            [ivar, T.let(object.instance_variable_get(ivar), Object)]
          end
        end
      end
    end
  end
end
