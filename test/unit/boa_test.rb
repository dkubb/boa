# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa do
  extend T::Sig

  sig { returns(T::Class[Boa]) }
  def described_class
    Person
  end

  subject { described_class.new }

  describe '.new' do
    cover 'Boa#initialize'

    describe 'with a T::Struct object' do
      sig { returns(T::Class[Boa]) }
      def described_class
        @described_class ||=
          Class.new(T::Struct) do
            include Boa

            prop :name, String

            finalize
          end
      end

      describe 'with no attributes' do
        it 'raises an error' do
          assert_raises(ArgumentError) { subject }
        end
      end

      describe 'with attributes' do
        subject { described_class.new(name: 'Dan Kubb') }

        it 'initializes the object' do
          assert_kind_of(described_class, subject)
        end

        it 'sets the name' do
          assert_equal('Dan Kubb', subject.name)
        end
      end

      describe 'with unknown attributes' do
        # provide attributes in reverse order to ensure that the error
        # message sorts the attributes
        subject { described_class.new(unknown_b: nil, unknown_a: nil) }

        it 'raises an error' do
          error = assert_raises(Boa::UnknownAttributeError) { subject }

          assert_equal('Unknown attributes: unknown_a, unknown_b', error.message)
        end
      end
    end

    describe 'with a non-T::Struct object' do
      describe 'with no attributes' do
        it 'initializes the object' do
          assert_kind_of(described_class, subject)
        end

        it 'does not set the name' do
          assert_nil(subject.name)
        end
      end

      describe 'with attributes' do
        subject { described_class.new(name: 'Dan Kubb') }

        it 'initializes the object' do
          assert_kind_of(described_class, subject)
        end

        it 'sets the name' do
          assert_equal('Dan Kubb', subject.name)
        end
      end

      describe 'with unknown attributes' do
        # provide attributes in reverse order to ensure that the error
        # message sorts the attributes
        subject { described_class.new(unknown_b: nil, unknown_a: nil) }

        it 'raises an error' do
          error = assert_raises(Boa::UnknownAttributeError) { subject }

          assert_equal('Unknown attributes: unknown_a, unknown_b', error.message)
        end
      end
    end
  end

  describe '#==' do
    cover 'Boa::Equality#=='

    describe 'when the objects have equivalent state' do
      it 'returns true' do
        assert_equal(subject, subject.dup)
      end
    end

    describe 'when the objects have different state' do
      it 'returns false' do
        refute_equal(subject, described_class.new(name: 'Dan Kubb'))
      end
    end

    describe 'when the objects have the same state, but one is a subclass' do
      it 'returns true' do
        subclass = Class.new(described_class)

        assert_equal(subject, subclass.new)
      end
    end
  end

  describe 'eql?' do
    cover 'Boa::Equality#eql?'

    describe 'when the objects have equivalent state' do
      it 'returns true' do
        assert_operator(subject, :eql?, subject.dup)
      end
    end

    describe 'when the objects have different state' do
      it 'returns false' do
        other = described_class.new(name: 'Dan Kubb')

        refute_operator(subject, :eql?, other)
      end
    end

    describe 'when the objects have the same state, but one is a subclass' do
      it 'returns false' do
        subclass = Class.new(described_class)

        refute_operator(subject, :eql?, subclass.new)
      end
    end
  end

  describe '#hash' do
    cover 'Boa::Equality#hash'

    it 'returns an integer' do
      assert_kind_of(Integer, subject.hash)
    end

    it 'returns the same value for equal objects' do
      assert_equal(subject.hash, subject.dup.hash)
    end

    it 'returns a different values for different objects' do
      other = described_class.new(name: 'Dan Kubb')

      refute_equal(subject.hash, other.hash)
    end
  end
end
