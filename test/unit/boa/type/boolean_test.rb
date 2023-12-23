# typed: strong
# frozen_string_literal: true

require 'test_helper'

require_relative '../type_test'

module Boa
  class Test
    class Type
      class Boolean < Minitest::Test
        extend T::Sig
        include Support::InstanceMethodsBehaviour::Setup
        include Support::TypeBehaviour::Setup

        parallelize_me!

        sig { override.returns(T.class_of(Boa::Type::Boolean)) }
        def described_class
          Boa::Type::Boolean
        end

        sig { override.returns(Boa::Type::Boolean) }
        def state_inequality
          @state_inequality ||= T.let(described_class.new(:inequal), T.nilable(Boa::Type::Boolean))
        end

        sig { override.params(klass: T::Class[Boa::InstanceMethods]).returns(Boa::Type::Boolean) }
        def new_object(klass)
          raise(ArgumentError, "klass must be a Boa::Type::Boolean, but was #{klass}") unless klass <= Boa::Type::Boolean

          klass.new(type_name, **options)
        end

        sig { void }
        def test_class_hierarchy
          assert_operator(Boa::Type, :>, described_class)
          assert_equal(Boa::Type::Boolean, described_class)
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
          include Support::TypeBehaviour::New

          sig { override.returns(T::Boolean) }
          def non_nil_default
            false
          end

          sig { override.returns(T::Array[T::Boolean]) }
          def default_includes
            [true, false]
          end
        end

        class Name < self
          include Support::TypeBehaviour::Name
        end

        class Includes < self
          include Support::TypeBehaviour::Includes

          sig { override.returns(T::Array[T::Boolean]) }
          def includes
            @includes ||= T.let([true], T.nilable(T::Array[T::Boolean]))
          end
        end

        class Options < self
          include Support::TypeBehaviour::Options
        end

        class Default < self
          include Support::TypeBehaviour::Default

          sig { override.returns(T::Boolean) }
          def default
            false
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

        class DeconstructKeys < self
          include Support::InstanceMethodsBehaviour::DeconstructKeys

          sig { override.returns(T::Hash[Symbol, ::Object]) }
          def expected_object_state
            { name: type_name, includes: [true, false], options: {} }
          end
        end
      end
    end
  end
end
