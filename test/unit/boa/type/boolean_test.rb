# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Boolean do
  extend T::Sig

  subject { described_class.new(type_name) }

  sig { returns(T::Class[Boa::Type]) }
  def described_class
    Boa::Type::Boolean
  end

  sig { returns(Symbol) }
  def type_name
    :admin
  end

  sig { returns(T::Boolean) }
  def value
    false
  end

  sig { returns(Boa::Type) }
  def other
    described_class.new(other_type_name, **other_options)
  end

  sig { returns(Symbol) }
  def other_type_name
    type_name
  end

  sig { returns(T::Hash[Symbol, Object]) }
  def other_options
    {}
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

    describe 'when the ivar is true' do
      cover 'Boa::Type::Boolean#add_methods'

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
      cover 'Boa::Type::Boolean#add_methods'

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
      cover 'Boa::Type::Boolean#add_methods'

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
