# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Object do
  extend T::Sig
  include Support::EqualityBehaviour
  include Support::TypeBehaviour

  subject { described_class.new(type_name, **options) }

  let(:described_class)   { Boa::Type::Object                                }
  let(:type_name)         { :object                                          }
  let(:options)           { { default: 1 }                                   }
  let(:other)             { other_class.new(other_name, **other_options)     }
  let(:other_class)       { described_class                                  }
  let(:other_name)        { type_name                                        }
  let(:other_options)     { options                                          }
  let(:different_state)   { other_class.new(:different)                      }
  let(:not_eql_state)     { other_class.new(other_name, **not_eql_options)   }
  let(:not_eql_options)   { { default: 1.0 }                                 }

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
    include_examples 'Boa::Equality#=='
  end

  describe '#eql' do
    include_examples 'Boa::Equality#eql?'
  end

  describe '#hash' do
    include_examples 'Boa::Equality#hash'
  end
end
