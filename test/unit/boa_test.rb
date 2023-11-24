# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa do
  extend T::Sig

  sig { returns(T::Class[Boa]) }
  def described_class
    Person
  end

  subject { described_class.new(name: 'Dan Kubb') }

  describe '.new' do
    cover 'Boa#initialize'

    sig { returns(T::Class[Boa]) }
    def described_class
      @described_class ||=
        Class.new(T::Struct) do
          include Boa

          prop :name, String
        end
    end

    describe 'with no attributes' do
      it 'raises an error' do
        assert_raises(ArgumentError) do
          described_class.new
        end
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
      it 'raises an error' do
        error =
          assert_raises(ArgumentError) do
            described_class.new(unknown: nil)
          end

        assert_equal('Missing required prop `name` for class ``', error.message)
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
        refute_equal(subject, described_class.new(name: 'Other Name'))
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
        other = described_class.new(name: 'Other Name')

        refute_operator(subject, :eql?, other)
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
      other = described_class.new(name: 'Other Name')

      refute_equal(subject.hash, other.hash)
    end
  end
end
