# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Object do
  extend T::Sig
  include Support::TypeBehaviour

  subject { described_class.new(type_name) }

  let(:described_class)   { Boa::Type::Object                            }
  let(:type_name)         { :object                                      }
  let(:options)           { {}                                           }
  let(:other)             { other_class.new(other_name, **other_options) }
  let(:other_class)       { described_class                              }
  let(:other_name)        { type_name                                    }
  let(:other_options)     { options                                      }
  let(:different_options) { { default: Object.new }                      }

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

    cover 'Boa::Type::Object#initiaize'

    let(:default_includes) { nil        }
    let(:non_nil_default)  { Object.new }
  end

  describe '#name' do
    include_examples 'Boa::Type#name'
  end

  describe '#includes' do
    include_examples 'Boa::Type#includes'

    let(:includes) { [Object.new] }
  end

  describe '#options' do
    include_examples 'Boa::Type#options'
  end

  describe '#default' do
    include_examples 'Boa::Type#default'

    let(:default) { Object.new }
  end

  describe '#==' do
    include_examples 'Boa::Type#=='

    it 'is false when object state is equal but does not eql?' do
      subject = described_class.new(type_name, default: 1)
      other   = described_class.new(type_name, default: 1.0)

      assert_equal(subject, other)
      refute_operator(subject, :eql?, other)
    end
  end

  describe '#eql' do
    include_examples 'Boa::Type#eql?'
  end

  describe '#hash' do
    include_examples 'Boa::Type#hash'
  end
end
