# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Boolean do
  extend T::Sig

  subject { described_class.new(type_name, **options) }

  sig { returns(T.class_of(Boa::Type)) }
  def described_class
    Boa::Type::Boolean
  end
  alias_method(:other_class, :described_class)

  sig { returns(Symbol) }
  def type_name
    :admin
  end
  alias_method(:other_name, :type_name)

  sig { returns(T::Hash[Symbol, Object]) }
  def options
    {}
  end
  alias_method(:other_options, :options)

  sig { returns(Boa::Type) }
  def other
    other_class.new(other_name, **other_options)
  end

  sig { returns(T::Hash[Symbol, Object]) }
  def different_options
    { default: false }
  end

  sig { returns(T::Boolean) }
  def value
    false
  end

  describe '.new' do
    include Support::TypeBehaviour::New

    cover 'Boa::Type::Boolean#initialize'

    sig { returns(T.nilable(Object)) }
    def default_includes
      [true, false]
    end

    sig { returns(T.nilable(Object)) }
    def non_nil_default
      true
    end
  end

  describe '#init' do
    include Support::TypeBehaviour::Init
  end

  describe '#get' do
    include Support::TypeBehaviour::Get
  end

  describe '#set' do
    include Support::TypeBehaviour::Set
  end

  describe '#==' do
    include Support::TypeBehaviour::Equality
  end

  describe '#eql' do
    include Support::TypeBehaviour::Eql
  end

  describe '#hash' do
    include Support::TypeBehaviour::Hash
  end

  describe '#add_methods' do
    include Support::TypeBehaviour::AddMethods

    cover 'Boa::Type::Boolean#add_methods'

    describe 'when the ivar is true' do
      sig { returns(T::Boolean) }
      def value
        true
      end

      it 'adds a query method' do
        instance = klass.new(type_name => value)

        refute_respond_to(instance, :"#{type_name}?")

        subject.add_methods(klass)

        assert_respond_to(instance, :"#{type_name}?")
        assert_same(value, instance.admin?)
      end

      it 'returns self' do
        assert_same(subject, subject.add_methods(klass))
      end
    end

    describe 'when the ivar is false' do
      sig { returns(T::Boolean) }
      def value
        false
      end

      it 'adds a query method' do
        instance = klass.new(type_name => value)

        refute_respond_to(instance, :"#{type_name}?")

        subject.add_methods(klass)

        assert_respond_to(instance, :"#{type_name}?")
        assert_same(value, instance.admin?)
      end

      it 'returns self' do
        assert_same(subject, subject.add_methods(klass))
      end
    end

    describe 'when the ivar is nil' do
      it 'adds a query method' do
        instance = klass.new

        refute_respond_to(instance, :"#{type_name}?")

        subject.add_methods(klass)

        assert_respond_to(instance, :"#{type_name}?")
        assert_same(false, instance.admin?)
      end

      it 'returns self' do
        assert_same(subject, subject.add_methods(klass))
      end
    end
  end

  describe '#finalize' do
    include Support::TypeBehaviour::Finalize
  end
end
