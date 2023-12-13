# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa do
  extend T::Sig
  include Support::EqualityBehaviour

  subject { described_class.new(**options) }

  let(:described_class) do
    Class.new(T::InexactStruct) do
      include Boa

      const :name, String
    end
  end

  let(:options)         { { name: 'Dan Kubb' }                }
  let(:other)           { other_class.new(**other_options)    }
  let(:other_class)     { described_class                     }
  let(:other_options)   { options                             }
  let(:different_state) { other_class.new(name: 'Other Name') }

  describe '.new' do
    cover 'Boa#initialize'

    describe 'with no attributes' do
      it 'raises an error' do
        error =
          assert_raises(ArgumentError) do
            described_class.new
          end

        assert_equal('Missing required prop `name` for class ``', error.message)
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
    include_examples 'Boa::Equality#=='
  end

  describe '#eql?' do
    include_examples 'Boa::Equality#eql?'
  end

  describe '#hash' do
    include_examples 'Boa::Equality#hash'
  end
end
