# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Boolean do
  extend T::Sig

  subject { described_class.new(type_name, **options) }

  sig { returns(T.class_of(Boa::Type)) }
  def described_class
    Boa::Type::Boolean
  end
  alias_method(:other_class, :described_class)

  sig { returns(Symbol) }
  def type_name
    :admin
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
    { default: false }
  end

  describe '.new' do
    include Support::TypeBehaviour::New

    cover 'Boa::Type::Boolean#initialize'

    sig { returns(T.nilable(Object)) }
    def default_includes
      [true, false]
    end

    sig { returns(T.nilable(Object)) }
    def non_nil_default
      true
    end
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
end
