# typed: strong
# frozen_string_literal: true

require 'test_helper'

require_relative '../type_test'

module Boa
  class Test
    class Type
      class Object < Minitest::Test
        extend T::Sig
        include Support::InstanceMethodsBehaviour::Setup
        include Support::TypeBehaviour::Setup

        parallelize_me!

        sig { override.returns(T.class_of(Boa::Type::Object)) }
        def described_class
          Boa::Type::Object
        end

        sig { override.returns(Boa::Type::Object) }
        def state_ineql
          @state_ineql ||= T.let(described_class.new(type_name, default: 1.0), T.nilable(Boa::Type::Object))
        end

        sig { override.returns(Boa::Type::Object) }
        def state_inequality
          @state_inequality ||= T.let(described_class.new(:inequal), T.nilable(Boa::Type::Object))
        end

        sig { override.params(klass: T::Class[Boa::InstanceMethods]).returns(Boa::Type::Object) }
        def new_object(klass)
          raise(ArgumentError, "klass must be a Boa::Type::Object, but was #{klass}") unless klass <= Boa::Type::Object

          klass.new(type_name, **options)
        end

        sig { override.returns(T::Hash[Symbol, ::Object]) }
        def options
          { default: 1 }
        end

        sig { void }
        def test_class_hierarchy
          assert_operator(Boa::Type, :>, described_class)
          assert_equal(Boa::Type::Object, described_class)
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

          sig { override.returns(::Object) }
          def non_nil_default
            @non_nil_default ||= T.let(::Object.new, T.nilable(::Object))
          end

          sig { override.returns(NilClass) }
          def default_includes; end
        end

        class Name < self
          include Support::TypeBehaviour::Name
        end

        class Includes < self
          include Support::TypeBehaviour::Includes

          sig { override.returns(T::Array[::Object]) }
          def includes
            @includes ||= T.let([::Object.new], T.nilable(T::Array[::Object]))
          end
        end

        class Options < self
          include Support::TypeBehaviour::Options
        end

        class Default < self
          include Support::TypeBehaviour::Default

          sig { override.returns(::Object) }
          def default
            @default ||= T.let(::Object.new, T.nilable(::Object))
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
            { name: type_name, includes: nil, options: { default: 1 } }
          end
        end

        class Deconstruct < self
          include Support::InstanceMethodsBehaviour::Deconstruct

          sig { override.returns(T::Hash[Symbol, ::Object]) }
          def expected_object_state
            { name: type_name, includes: nil, options: { default: 1 } }
          end
        end
      end
    end
  end
end
