# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Integer do
  extend T::Sig
  include Support::EqualityBehaviour
  include Support::TypeBehaviour

  subject { described_class.new(type_name, **options) }

  let(:described_class)   { Boa::Type::Integer                           }
  let(:type_name)         { :integer                                     }
  let(:options)           { {}                                           }
  let(:other)             { other_class.new(other_name, **other_options) }
  let(:other_class)       { described_class                              }
  let(:other_name)        { type_name                                    }
  let(:other_options)     { options                                      }
  let(:different_state)   { other_class.new(:different)                  }

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

    let(:default_includes) { nil }
    let(:non_nil_default)  { 100 }

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
        let(:range) { 0..10 }

        it 'sets the range attribute' do
          assert_equal(0..10, subject.range)
        end
      end

      describe 'with no minimum range' do
        let(:range) { ..10 }

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

    let(:includes) { [1] }
  end

  describe '#options' do
    include_examples 'Boa::Type#options'
  end

  describe '#default' do
    include_examples 'Boa::Type#default'

    let(:default) { 1 }
  end

  describe '#min_range' do
    cover 'Boa::Type::Integer#min_range'

    subject { described_class.new(type_name, range:) }

    describe 'with no minimum range' do
      let(:range) { (..100) }

      it 'returns nil' do
        assert_nil(subject.min_range)
      end
    end

    describe 'with a minimum range' do
      let(:range) { 1..100 }

      it 'returns the minimum range' do
        assert_same(1, subject.min_range)
      end
    end
  end

  describe '#max_range' do
    cover 'Boa::Type::Integer#max_range'

    subject { described_class.new(type_name, range:) }

    describe 'with no maximum range' do
      let(:range) { 1.. }

      it 'returns nil' do
        assert_nil(subject.max_range)
      end
    end

    describe 'with a maximum range' do
      let(:range) { 1..100 }

      it 'returns the maximum range' do
        assert_same(100, subject.max_range)
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
