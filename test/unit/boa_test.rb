# typed: strong
# frozen_string_literal: true

require 'test_helper'

module Boa
  class Test < Minitest::Test
    extend T::Sig
    include Support::InstanceMethodsBehaviour::Setup

    parallelize_me!

    class Person < T::ImmutableStruct
      include Boa

      const :name, String
    end

    class InheritablePerson < T::InexactStruct
      extend T::Sig
      include Boa

      sig { params(name: String).void }
      def initialize(name:)
        @name = name
        super()
      end
    end

    sig { override.returns(T.class_of(Person)) }
    def described_class
      Person
    end

    sig { override.returns(T.class_of(InheritablePerson)) }
    def inheritable_class
      InheritablePerson
    end

    sig { override.returns(Person) }
    def state_inequality
      @state_inequality ||= T.let(described_class.new(name: 'Other Name'), T.nilable(Person))
    end

    sig { override.params(klass: T::Class[Boa::InstanceMethods]).returns(Boa::InstanceMethods) }
    def new_object(klass)
      klass.new(**options)
    end

    sig { returns(T::Hash[Symbol, Object]) }
    def options
      { name: name_value }
    end

    sig { returns(String) }
    def name_value
      'Dan Kubb'
    end

    sig { void }
    def test_class_hierarchy
      assert_operator(Boa, :>, described_class)
      assert_same(Person, described_class)
    end

    class New < self
      sig { void }
      def test_new_with_attributes
        subject = described_class.new(name: name_value)

        assert_instance_of(described_class, subject)
        assert_same(name_value, subject.name)
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

      sig { override.returns(T::Hash[Symbol, Object]) }
      def expected_object_state
        options
      end
    end

    class Deconstruct < self
      include Support::InstanceMethodsBehaviour::Deconstruct

      sig { override.returns(T::Hash[Symbol, Object]) }
      def expected_object_state
        options
      end
    end
  end
end
