# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Integer do
  extend T::Sig
  include Support::TypeBehaviour

  subject { described_class.new(type_name, **options) }

  sig { returns(T.class_of(Boa::Type)) }
  def described_class
    Boa::Type::Integer
  end
  alias_method(:other_class, :described_class)

  sig { returns(Symbol) }
  def type_name
    :age
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
    { default: 42 }
  end

  describe '.[]' do
    include_examples 'Boa::Type.[]'
  end

  describe '.[]=' do
    include_examples 'Boa::Type.[]='
  end

  describe '.class_type' do
    include_examples 'Boa::Type.class_type'
  end

  describe '.inherited' do
    include_examples 'Boa::Type.inherited'
  end

  describe '.new' do
    include_examples 'Boa::Type.new'

    cover 'Boa::Type::Integer#initialize'

    sig { returns(T.nilable(Object)) }
    def default_includes
      nil
    end

    sig { returns(T.nilable(Integer)) }
    def non_nil_default
      100
    end

    describe 'with default option' do
      subject { described_class.new(type_name, default: 42) }

      it 'sets the default attribute' do
        assert_same(42, subject.default)
      end
    end

    describe 'with no range option' do
      it 'sets the range attribute to the default' do
        assert_equal(nil.., subject.range)
      end
    end

    describe 'with a range option' do
      subject { described_class.new(type_name, range:) }

      describe 'with a minimum range' do
        sig { returns(T::Range[T.nilable(Integer)]) }
        def range
          0..10
        end

        it 'sets the range attribute' do
          assert_equal(0..10, subject.range)
        end
      end

      describe 'with no minimum range' do
        sig { returns(T::Range[T.nilable(Integer)]) }
        def range
          (..10)
        end

        it 'sets the range attribute' do
          assert_equal(..10, subject.range)
        end
      end
    end
  end

  describe '#name' do
    include_examples 'Boa::Type#name'
  end

  describe '#includes' do
    include_examples 'Boa::Type#includes'

    sig { returns(Object) }
    def includes
      @includes ||= [1]
    end
  end

  describe '#options' do
    include_examples 'Boa::Type#options'
  end

  describe '#min_range' do
    cover 'Boa::Type::Integer#min_range'

    subject { described_class.new(type_name, range:) }

    describe 'with no minimum range' do
      sig { returns(T::Range[Integer]) }
      def range
        (..100)
      end

      it 'returns nil' do
        assert_nil(subject.min_range)
      end
    end

    describe 'with a minimum range' do
      sig { returns(T::Range[Integer]) }
      def range
        1..100
      end

      it 'returns the minimum range' do
        assert_same(1, subject.min_range)
      end
    end
  end

  describe '#max_range' do
    cover 'Boa::Type::Integer#max_range'

    subject { described_class.new(type_name, range:) }

    describe 'with no maximum range' do
      sig { returns(T::Range[Integer]) }
      def range
        1..
      end

      it 'returns nil' do
        assert_nil(subject.max_range)
      end
    end

    describe 'with a maximum range' do
      sig { returns(T::Range[Integer]) }
      def range
        1..100
      end

      it 'returns the maximum range' do
        assert_same(100, subject.max_range)
      end
    end
  end

  describe '#==' do
    include_examples 'Boa::Type#=='
  end

  describe '#eql?' do
    include_examples 'Boa::Type#eql?'
  end

  describe '#hash' do
    include_examples 'Boa::Type#hash'
  end
end
