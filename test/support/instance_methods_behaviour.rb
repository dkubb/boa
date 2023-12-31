# typed: strong
# frozen_string_literal: true

require 'minitest/test'

module Support
  module InstanceMethodsBehaviour
    module Setup
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Minitest::Test }

      abstract!

      sig { abstract.returns(T::Class[Boa::InstanceMethods]) }
      def described_class; end

      sig { overridable.returns(T::Class[Boa::InstanceMethods]) }
      def inheritable_class
        described_class
      end

      sig { overridable.returns(Object) }
      def state_ineql
        raise(NotImplementedError, "#{self.class}##{__method__} is not implemented")
      end

      sig { abstract.returns(Object) }
      def state_inequality; end

      sig { abstract.params(klass: T::Class[Boa::InstanceMethods]).returns(Boa::InstanceMethods) }
      def new_object(klass) end
    end

    module Contexts
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Minitest::Test }

      abstract!

      sig { abstract.void }
      def test_objects_have_similar_state; end

      sig { abstract.void }
      def test_objects_similar_state_but_other_is_subclass; end

      sig { abstract.void }
      def test_objects_different_classes; end

      sig { abstract.void }
      def test_objects_inequality; end

      sig { abstract.void }
      def test_objects_similar_but_not_equal_state; end

      sig { abstract.void }
      def test_non_instance_method_object; end
    end

    module Equality
      extend T::Helpers
      extend T::Sig
      include Contexts

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::InstanceMethods#==')
      end

      sig { override.void }
      def test_objects_have_similar_state
        subject = new_object(described_class)
        other   = subject.dup

        assert_equal(subject, other)
        refute_same(subject, other)
      end

      sig { override.void }
      def test_objects_similar_state_but_other_is_subclass
        subject = new_object(inheritable_class)
        other   = new_object(Class.new(inheritable_class))

        assert_equal(subject, other)
        refute_same(subject, other)
      end

      sig { override.void }
      def test_objects_different_classes
        subject = new_object(Class.new(inheritable_class))
        other   = new_object(Class.new(inheritable_class))

        refute_equal(subject, other)
      end

      sig { override.void }
      def test_objects_inequality
        subject = new_object(described_class)

        refute_equal(subject, state_inequality)
      end

      sig { override.void }
      def test_objects_similar_but_not_equal_state
        subject = new_object(described_class)

        assert_same(subject.class, state_ineql.class)
        assert_equal(subject, state_ineql)
      rescue NotImplementedError
        # skip if state_ineql impossible to define for this type
      end

      sig { override.void }
      def test_non_instance_method_object
        subject = new_object(described_class)
        other   = BasicObject.new

        refute_equal(subject, other)
      end
    end

    module Eql
      extend T::Helpers
      extend T::Sig
      include Contexts

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::InstanceMethods#eql?')
      end

      sig { override.void }
      def test_objects_have_similar_state
        subject = new_object(described_class)
        other   = subject.dup

        assert_operator(subject, :eql?, other)
        refute_same(subject, other)
      end

      sig { override.void }
      def test_objects_similar_state_but_other_is_subclass
        subject = new_object(inheritable_class)
        other   = new_object(Class.new(inheritable_class))

        refute_operator(subject, :eql?, other)
      end

      sig { override.void }
      def test_objects_different_classes
        subject = new_object(Class.new(inheritable_class))
        other   = new_object(Class.new(inheritable_class))

        refute_operator(subject, :eql?, other)
      end

      sig { override.void }
      def test_objects_inequality
        subject = new_object(described_class)

        refute_operator(subject, :eql?, state_inequality)
      end

      sig { override.void }
      def test_objects_similar_but_not_equal_state
        subject = new_object(described_class)

        assert_same(subject.class, state_ineql.class)
        refute_operator(subject, :eql?, state_ineql)
      rescue NotImplementedError
        # skip if state_ineql impossible to define for this type
      end

      sig { override.void }
      def test_non_instance_method_object
        subject = new_object(described_class)
        other   = BasicObject.new

        # refute_operator does not work with BasicObject and sorbet
        refute(subject.eql?(other))
      end
    end

    module Hash
      extend T::Helpers
      extend T::Sig
      include Contexts

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::InstanceMethods#hash')
      end

      sig { override.void }
      def test_objects_have_similar_state
        subject = new_object(described_class)
        other   = subject.dup

        assert_same(subject.hash, other.hash)
      end

      sig { override.void }
      def test_objects_similar_state_but_other_is_subclass
        subject = new_object(inheritable_class)
        other   = new_object(Class.new(inheritable_class))

        refute_equal(subject.hash, other.hash)
      end

      sig { override.void }
      def test_objects_different_classes
        subject = new_object(Class.new(inheritable_class))
        other   = new_object(Class.new(inheritable_class))

        refute_equal(subject.hash, other.hash)
      end

      sig { override.void }
      def test_objects_inequality
        subject = new_object(described_class)

        refute_equal(subject.hash, state_inequality.hash)
      end

      sig { override.void }
      def test_objects_similar_but_not_equal_state
        subject = new_object(described_class)

        refute_equal(subject.hash, state_ineql.hash)
      rescue NotImplementedError
        # skip if state_ineql impossible to define for this type
      end

      sig { override.void }
      def test_non_instance_method_object
        subject = new_object(described_class)
        other   = Object.new # BasicObject#hash does not exist

        refute_equal(subject.hash, other.hash)
      end
    end

    module DeconstructKeys
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      abstract!

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::InstanceMethods#deconstruct_keys')
      end

      sig { abstract.returns(T::Hash[Symbol, Object]) }
      def expected_object_state; end

      sig { void }
      def test_deconstruct_keys_with_nil
        subject = new_object(described_class)

        assert_equal(expected_object_state, subject.deconstruct_keys(nil))
      end

      sig { void }
      def test_deconstruct_keys_with_property_names
        subject = new_object(described_class)

        assert_equal(expected_object_state, subject.deconstruct_keys(expected_object_state.keys))
      end

      sig { void }
      def test_deconstruct_keys_with_invalid_property_names
        subject = new_object(described_class)

        assert_empty(subject.deconstruct_keys(%i[invalid]))
      end

      sig { void }
      def test_pattern_matching
        subject  = new_object(described_class)
        expected = T.let(expected_object_state, T::Hash[Symbol, T.anything])

        assert_pattern do
          T.unsafe(subject => expected) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Sorbet/ForbidTUnsafe
        end
      end
    end

    module Deconstruct
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      abstract!

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::InstanceMethods#deconstruct')
      end

      sig { abstract.returns(T::Hash[Symbol, Object]) }
      def expected_object_state; end

      sig { void }
      def test_deconstruct
        subject = new_object(described_class)

        assert_equal(expected_object_state.values, subject.deconstruct)
      end

      sig { void }
      def test_pattern_matching
        subject  = new_object(described_class)
        expected = T.let(expected_object_state.values, T::Array[T.anything])

        assert_pattern do
          T.unsafe(subject => expected) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Sorbet/ForbidTUnsafe
        end
      end
    end
  end
end
