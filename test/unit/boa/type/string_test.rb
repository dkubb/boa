# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::String do
  extend T::Sig
  include Support::TypeBehaviour

  subject { described_class.new(type_name, **options) }

  sig { returns(T.class_of(Boa::Type)) }
  def described_class
    Boa::Type::String
  end
  alias_method(:other_class, :described_class)

  sig { returns(Symbol) }
  def type_name
    :name
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
    { default: 'Other Name' }
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

    cover 'Boa::Type::String#initialize'

    sig { returns(T.nilable(Object)) }
    def default_includes
      nil
    end

    sig { returns(T.nilable(Object)) }
    def non_nil_default
      'Jon'
    end

    describe 'with default option' do
      subject { described_class.new(type_name, default: 'default') }

      it 'sets the default attribute' do
        assert_same('default', subject.default)
      end
    end

    describe 'with no length option' do
      it 'sets the length attribute to the default' do
        assert_equal(0.., subject.length)
      end

      it 'has the expected default minimum length' do
        assert_equal(0, subject.min_length)
      end

      it 'has the expected default maximum length' do
        assert_nil(subject.max_length)
      end
    end

    describe 'with length option' do
      subject { described_class.new(type_name, length: min_length..10) }

      describe 'with a non-nil minimum length' do
        sig { returns(T.nilable(Integer)) }
        def min_length
          2
        end

        it 'sets the length attribute' do
          assert_equal(2..10, subject.length)
        end

        it 'has the expected minimum length' do
          assert_equal(2, subject.min_length)
        end

        it 'has the expected default maximum length' do
          assert_equal(10, subject.max_length)
        end
      end

      describe 'with a nil minimum length' do
        sig { returns(T.nilable(Integer)) }
        def min_length; end

        it 'sets the length attribute' do
          assert_equal(0..10, subject.length)
        end

        it 'has the expected minimum length' do
          assert_same(0, subject.min_length)
        end

        it 'has the expected default maximum length' do
          assert_same(10, subject.max_length)
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
      @includes ||= %w[test]
    end
  end

  describe '#options' do
    include_examples 'Boa::Type#options'
  end

  describe '#min_length' do
    cover 'Boa::Type::String#min_length'

    it 'returns the minimum length' do
      assert_equal(0, subject.min_length)
    end
  end

  describe '#max_length' do
    cover 'Boa::Type::String#max_length'

    describe 'with no maximum length' do
      describe 'with an inclusive range' do
        it 'returns nil' do
          assert_nil(subject.max_length)
        end
      end

      describe 'with an exclusive range' do
        subject { described_class.new(type_name, length:) }

        sig { returns(T::Range[Integer]) }
        def length
          (1...)
        end

        it 'returns nil' do
          assert_nil(subject.max_length)
        end
      end
    end

    describe 'with a maximum length' do
      subject { described_class.new(type_name, length:) }

      describe 'with an inclusive range' do
        sig { returns(T::Range[Integer]) }
        def length
          1..10
        end

        it 'returns the maximum length' do
          assert_equal(10, subject.max_length)
        end
      end

      describe 'with an exclusive range' do
        sig { returns(T::Range[Integer]) }
        def length
          1...10
        end

        it 'returns the maximum length' do
          assert_equal(9, subject.max_length)
        end
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
