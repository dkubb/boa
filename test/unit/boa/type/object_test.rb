# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Object do
  extend T::Sig

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

  sig { returns(Object) }
  def value
    @value ||= Object.new
  end

  describe '.new' do
    include Support::TypeBehaviour::New

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

  describe '#init' do
    include Support::TypeBehaviour::Init
  end

  describe '#get' do
    include Support::TypeBehaviour::Get
  end

  describe '#set' do
    include Support::TypeBehaviour::Set
  end

  describe '#==' do
    include Support::TypeBehaviour::Equality

    it 'is false when object state is equal but does not eql?' do
      subject = described_class.new(type_name, default: 1)
      other   = described_class.new(type_name, default: 1.0)

      assert_equal(subject, other)
      refute_operator(subject, :eql?, other)
    end
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
