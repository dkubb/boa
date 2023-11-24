# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Integer do
  extend T::Sig

  subject { described_class.new(type_name) }

  sig { returns(T::Class[Boa::Type]) }
  def described_class
    Boa::Type::Integer
  end
  alias_method(:other_class, :described_class)

  sig { returns(Symbol) }
  def type_name
    :version
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
    { default: 1 }
  end

  sig { returns(Integer) }
  def value
    @value ||= 1
  end

  describe '.new' do
    include Support::TypeBehaviour::New

    cover 'Boa::Type::Integer#initiaize'

    sig { returns(T.nilable(Integer)) }
    def default_includes
      nil
    end

    sig { returns(T.nilable(Integer)) }
    def non_nil_default
      @non_nil_default ||= 0
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
