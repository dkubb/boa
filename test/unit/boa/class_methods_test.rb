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
          PropCheck.forall(PropertyGenerators::Type.instance) do |type|
            type    = T.let(type, Boa::Type)
            subject = Class.new(described_class)

            assert_empty(subject.properties)

            subject.properties[type.name] = type

            assert_equal({ type.name => type }, subject.properties)
          end
        end
      end

      class Prop < self
        extend MutantCoverage

        cover 'Boa::ClassMethods#properties'

        sig { void }
        def test_prop_sets_the_property
          PropCheck.forall(PropertyGenerators::Type.instance) do |type|
            type       = T.let(type, Boa::Type)
            subject    = Class.new(described_class)
            class_type = class_types.fetch(type.class)

            assert_empty(subject.properties)

            subject.prop(type.name, class_type, includes: type.includes)

            assert_equal({ type.name => type }, subject.properties)
          end
        end

        sig { void }
        def test_prop_returns_self
          PropCheck.forall(PropertyGenerators::Type.instance) do |type|
            type       = T.let(type, Boa::Type)
            subject    = Class.new(described_class)
            class_type = class_types.fetch(type.class)

            assert_same(subject, subject.prop(type.name, class_type))
          end
        end

        sig { void }
        def test_passes_through_the_options
          PropCheck.forall(PropertyGenerators::Type.instance) do |type|
            type       = T.let(type, Boa::Type)
            subject    = Class.new(described_class)
            class_type = T.let(class_types.fetch(type.class), Boa::Type::ClassType)

            refute_operator(subject, :public_method_defined?, type.name)
            refute_operator(subject, :public_method_defined?, :"#{type.name}=")

            subject.prop(type.name, class_type, immutable: true)

            # assert the immutable true option prevents the setter from being defined
            assert_operator(subject, :public_method_defined?, type.name)
            refute_operator(subject, :public_method_defined?, :"#{type.name}=")
          end
        end

      private

        sig { returns(T::Hash[T.class_of(Boa::Type), Boa::Type::ClassType]) }
        def class_types
          @class_types ||= T.let(
            Boa::Type.class_types.invert,
            T.nilable(T::Hash[T.class_of(Boa::Type), Boa::Type::ClassType])
          )
        end
      end

      class Freeze < self
        extend MutantCoverage

        cover 'Boa::ClassMethods#freeze'

        sig { void }
        def test_freezes_the_instance_variables
          subject = Class.new(described_class)

          ivars(subject).each_value do |value|
            refute_predicate(value, :frozen?)
          end

          subject.freeze

          ivars(subject).each_value do |value|
            assert_predicate(value, :frozen?)
          end
        end

        sig { void }
        def test_freezes_the_class
          subject = Class.new(described_class)

          assert_predicate(subject.freeze, :frozen?)
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
