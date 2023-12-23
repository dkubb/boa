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
    end

    module InstanceMethods
      extend T::Helpers
      extend T::Sig
      include Contexts

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::InstanceMethods#==')
        descendant.cover('Boa::InstanceMethods#object_state')
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
    end

    module Eql
      extend T::Helpers
      extend T::Sig
      include Contexts

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::InstanceMethods#eql?')
        descendant.cover('Boa::InstanceMethods#object_state')
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
    end

    module Hash
      extend T::Helpers
      extend T::Sig
      include Contexts

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::InstanceMethods#hash')
        descendant.cover('Boa::InstanceMethods#object_state')
      end

      sig { override.void }
      def test_objects_have_similar_state
        subject = new_object(described_class)
        other   = subject.dup

        assert_equal(subject.hash, other.hash)
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
    end
  end
end
