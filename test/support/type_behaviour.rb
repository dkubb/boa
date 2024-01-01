# typed: strong
# frozen_string_literal: true

module Support
  module TypeBehaviour
    module Setup
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Minitest::Test }

      abstract!

      sig { abstract.returns(T.class_of(Boa::Type)) }
      def described_class; end

      sig { returns(Symbol) }
      def type_name
        :type_name
      end

      sig { overridable.returns(T::Hash[Symbol, T.untyped]) }
      def options
        {}
      end

      sig { overridable.returns(T.nilable(T::Array[T.untyped])) }
      def includes; end

      sig { returns(T::Hash[Boa::Type::ClassType, T.class_of(Boa::Type)]) }
      def class_types
        T.let(
          described_class.__send__(:class_types),
          T::Hash[Boa::Type::ClassType, T.class_of(Boa::Type)]
        )
      end

      sig { params(class_type: Boa::Type::ClassType).void }
      def remove_class_type(class_type)
        class_types.delete(class_type)
      end

      sig { params(klass: T.class_of(Object), method_name: Symbol, block: T.nilable(Proc)).void }
      def replace_method(klass, method_name, &block)
        original_verbose = $VERBOSE
        $VERBOSE         = nil

        # Replace the singleton method without warnings
        klass.define_singleton_method(method_name, &block)

        $VERBOSE = original_verbose
      end
    end

    module ElementReference
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type.[]')
      end

      sig { void }
      def test_when_class_type_is_set
        type_class = described_class[String]

        assert_same(Boa::Type::String, type_class)
      end

      sig { void }
      def test_when_class_type_is_not_set
        class_type = Class.new

        exception = T.let(
          assert_raises(ArgumentError) { described_class[class_type] },
          ArgumentError
        )

        assert_equal("type class for #{class_type} is unknown", exception.message)
      end
    end

    module ElementAssignment
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type.[]=')
      end

      sig { void }
      def test_sets_class_type
        assert_raises(ArgumentError) do
          described_class[class_type]
        end

        described_class[class_type] = type_class

        assert_same(type_class, described_class[class_type])
      ensure
        remove_class_type(class_type)
      end

    private

      sig { returns(Boa::Type::ClassType) }
      def class_type
        @class_type ||= T.let(Class.new, T.nilable(T::Class[T.anything]))
      end

      sig { returns(T.class_of(Boa::Type)) }
      def type_class
        @type_class ||= T.let(Class.new(described_class), T.nilable(T.class_of(Boa::Type)))
      end
    end

    module ClassType
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type.class_type')
      end

      sig { void }
      def test_sets_class_type
        assert_raises(ArgumentError) do
          described_class[class_type]
        end

        type = described_class.class_type(class_type)

        assert_same(described_class[class_type], type)
      ensure
        remove_class_type(class_type)
      end

    private

      sig { returns(Boa::Type::ClassType) }
      def class_type
        @class_type ||= T.let(Class.new, T.nilable(T::Class[T.anything]))
      end
    end

    module Inherited
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type.inherited')
      end

      sig { void }
      def test_sets_class_types
        subject = Class.new(described_class)

        assert_same(class_types, subject.__send__(:class_types))
      end

      sig { void }
      def test_calls_super
        described_class    = self.described_class
        original_inherited = described_class.method(:inherited)
        object_inherited   = Object.method(:inherited)
        inherited          = []

        replace_method(described_class, :inherited) do |descendant|
          inherited << described_class
          original_inherited.(descendant)
        end

        replace_method(Object, :inherited) do |descendant|
          inherited << Object
          object_inherited.(descendant)
        end

        Class.new(described_class)

        assert_equal([described_class, Object], inherited)

        replace_method(Object,          :inherited, &object_inherited)
        replace_method(described_class, :inherited, &original_inherited)
      end
    end

    module New
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      abstract!

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type.new')
        descendant.cover('Boa::Type#initialize')
      end

      sig { abstract.returns(Object) }
      def non_nil_default; end

      sig { abstract.returns(T.nilable(Object)) }
      def default_includes; end

      sig { void }
      def test_with_no_default_option
        subject = described_class.new(type_name)

        assert_same(type_name, subject.name)
        assert_nil(subject.default)
        assert_predicate(subject, :frozen?)
      end

      sig { void }
      def test_with_non_nil_default_option
        subject = described_class.new(type_name, default: non_nil_default)

        assert_same(type_name, subject.name)
        assert_same(non_nil_default, subject.default)
        assert_predicate(subject, :frozen?)
      end

      sig { void }
      def test_with_no_includes_option
        subject = described_class.new(type_name)

        assert_same(type_name, subject.name)

        if default_includes.nil?
          assert_nil(subject.includes)
        else
          assert_equal(default_includes, subject.includes)
        end

        assert_predicate(subject, :frozen?)
      end

      sig { void }
      def test_with_includes_option
        subject = described_class.new(type_name, includes: [])

        assert_same(type_name, subject.name)
        assert_empty(subject.includes)
        assert_predicate(subject, :frozen?)
      end
    end

    module Name
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type#name')
      end

      sig { void }
      def test_returns_the_name
        subject = described_class.new(type_name)

        assert_same(type_name, subject.name)
      end
    end

    module Includes
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      abstract!

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type#includes')
      end

      sig { void }
      def test_returns_the_includes
        subject = described_class.new(type_name, includes:)

        assert_same(includes, subject.includes)
      end
    end

    module Options
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      abstract!

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type#options')
      end

      sig { abstract.returns(T::Hash[Symbol, Object]) }
      def options; end

      sig { void }
      def test_returns_the_options
        subject = described_class.new(type_name, **options, includes:)

        assert_equal(options, subject.options)
      end
    end

    module Default
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      abstract!

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type#default')
      end

      sig { abstract.returns(T.nilable(Object)) }
      def default; end

      sig { void }
      def test_returns_default_option
        subject = described_class.new(type_name, default:)

        assert_same(default, subject.default)
      end

      sig { void }
      def test_returns_nil_when_no_default_option
        subject = described_class.new(type_name)

        assert_nil(subject.default)
      end
    end

    module Freeze
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      abstract!

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type#freeze')
      end

      sig { void }
      def test_freezes_the_instance_variables
        subject = described_class.allocate
        subject.instance_variable_set(:@name,     type_name)
        subject.instance_variable_set(:@includes, [])
        subject.instance_variable_set(:@options,  {})

        ivars(subject).each_value do |value|
          refute_predicate(value, :frozen?) unless value.equal?(type_name)
        end

        subject.freeze

        ivars(subject).each_value do |value|
          assert_predicate(value, :frozen?)
        end
      end

      sig { void }
      def test_freezes_the_type
        subject = described_class.new(type_name)

        assert_predicate(subject.freeze, :frozen?)
      end

      sig { void }
      def test_returns_the_type
        subject = described_class.new(type_name)

        assert_same(subject, subject.freeze)
      end

      sig { void }
      def test_does_not_mutate_arguments
        includes = []
        options  = { includes: }
        subject  = described_class.new(type_name, **options)

        subject.freeze

        # Argument is not mutated
        refute_predicate(includes, :frozen?)
        assert_predicate(subject.includes, :frozen?)

        # Argument state is copied
        refute_same(includes, subject.includes)
        assert_equal(includes, subject.includes)
      end

      sig { void }
      def test_idempotent
        subject = described_class.new(type_name)

        assert_same(subject.freeze, subject.freeze)
      end

    private

      sig { params(object: Object).returns(T::Hash[Symbol, Object]) }
      def ivars(object)
        object.instance_variables.to_h do |ivar|
          [ivar, T.let(object.instance_variable_get(ivar), Object)]
        end
      end
    end

    module Parse
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Setup }

      abstract!

      sig { params(descendant: MutantCoverage).void }
      def self.included(descendant)
        descendant.cover('Boa::Type.parse')
      end

      sig { abstract.returns(T.nilable(Object)) }
      def valid_value; end

      sig { abstract.returns(T.nilable(Object)) }
      def invalid_value; end

      sig { overridable.returns(T.nilable(T::Array[T.untyped])) }
      def includes
        @includes ||= T.let([valid_value], T.nilable(T::Array[T.untyped]))
      end

      sig { void }
      def test_when_includes_is_not_set
        subject = described_class.new(type_name)

        assert_equal(Boa::Success.new(valid_value), subject.parse(valid_value))
      end

      sig { void }
      def test_when_includes_is_set_and_value_is_valid
        subject = described_class.new(type_name, includes:)

        assert_equal(Boa::Success.new(valid_value), subject.parse(valid_value))
      end

      sig { void }
      def test_when_includes_is_set_and_value_is_invalid
        subject = described_class.new(type_name, includes:)

        assert_equal(
          Boa::Failure.new("must be one of #{includes.inspect}, but was #{invalid_value.inspect}"),
          subject.parse(invalid_value)
        )
      end
    end
  end
end
