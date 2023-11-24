# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::String do
  extend T::Sig

  subject { described_class.new(type_name, **options) }

  sig { returns(T::Class[Boa::Type]) }
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

  sig { returns(String) }
  def value
    'value'
  end

  describe '.new' do
    include Support::TypeBehaviour::New

    sig { returns(T.nilable(Object)) }
    def default_includes
      nil
    end

    sig { returns(T.nilable(Object)) }
    def non_nil_default
      'Jon'
    end

    describe 'with no required option' do
      cover 'Boa::Type::String#initialize'

      subject { described_class.new(type_name) }

      it 'sets the required attribute to true' do
        assert_operator(subject, :required?)
      end
    end

    describe 'with required option' do
      cover 'Boa::Type::String#initialize'

      subject { described_class.new(type_name, required: false) }

      it 'sets the required attribute to false' do
        refute_operator(subject, :required?)
      end
    end

    describe 'with default option' do
      subject { described_class.new(type_name, default: 'default') }

      it 'sets the default attribute' do
        assert_same('default', subject.default)
      end
    end

    describe 'with no length option' do
      it 'sets the length attribute to the default' do
        assert_equal(1.., subject.length)
      end

      it 'has the expected default minimum length' do
        assert_equal(1, subject.min_length)
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

        it 'raises an argument error' do
          error = assert_raises(ArgumentError) { subject }

          assert_equal('length.begin cannot be nil', error.message)
        end
      end
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

  describe '#min_length' do
    cover 'Boa::Type::String#min_length'

    it 'returns the minimum length' do
      assert_equal(1, subject.min_length)
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
  end

  describe '#finalize' do
    include Support::TypeBehaviour::Finalize
  end
end
