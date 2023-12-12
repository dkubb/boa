# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Object do
  extend T::Sig
  include Support::TypeBehaviour

  subject { described_class.new(type_name) }

  sig { returns(T.class_of(Boa::Type)) }
  def described_class
    Boa::Type::Object
  end
  alias_method(:other_class, :described_class)

  sig { returns(Symbol) }
  def type_name
    :state
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
    { default: Object.new }
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

    cover 'Boa::Type::Object#initiaize'

    sig { returns(T.nilable(Object)) }
    def default_includes
      nil
    end

    sig { returns(T.nilable(Object)) }
    def non_nil_default
      @non_nil_default ||= Object.new
    end
  end

  describe '#name' do
    include_examples 'Boa::Type#name'
  end

  describe '#includes' do
    include_examples 'Boa::Type#includes'

    sig { returns(Object) }
    def includes
      @includes ||= [Object.new]
    end
  end

  describe '#options' do
    include_examples 'Boa::Type#options'
  end

  describe '#default' do
    include_examples 'Boa::Type#default'

    sig { returns(Object) }
    def default
      @default ||= Object.new
    end
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
