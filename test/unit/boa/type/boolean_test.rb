# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Boolean do
  extend T::Sig
  include Support::EqualityBehaviour
  include Support::TypeBehaviour

  subject { described_class.new(type_name, **options) }

  let(:described_class)   { Boa::Type::Boolean                           }
  let(:type_name)         { :boolean                                     }
  let(:options)           { {}                                           }
  let(:other)             { other_class.new(other_name, **other_options) }
  let(:other_class)       { described_class                              }
  let(:other_name)        { type_name                                    }
  let(:other_options)     { options                                      }
  let(:different_state)   { other_class.new(:differemt)                  }

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

    cover 'Boa::Type::Boolean#initialize'

    let(:default_includes) { [true, false] }
    let(:non_nil_default)  { true          }
  end

  describe '#name' do
    include_examples 'Boa::Type#name'
  end

  describe '#includes' do
    include_examples 'Boa::Type#includes'

    let(:includes) { [true] }
  end

  describe '#options' do
    include_examples 'Boa::Type#options'
  end

  describe '#default' do
    include_examples 'Boa::Type#default'

    let(:default) { false }
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
