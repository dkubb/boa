# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type::Object do
  extend T::Sig

  subject { described_class.new(type_name) }

  sig { returns(T::Class[Boa::Type]) }
  def described_class
    Boa::Type::Object
  end

  sig { returns(Symbol) }
  def type_name
    :address
  end

  sig { returns(Object) }
  def value
    @value ||= {}
  end

  sig { returns(Boa::Type) }
  def other
    described_class.new(other_type_name, **other_options)
  end

  sig { returns(Symbol) }
  def other_type_name
    type_name
  end

  sig { returns(T::Hash[Symbol, Object]) }
  def other_options
    {}
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
      @non_nil_default ||= {}
    end

    describe 'when a block is provided' do
      it 'executes the block' do
        executed = false

        described_class.new(type_name) { executed = true }

        assert_same(true, executed)
      end

      it 'can call prop to set the properties' do
        subject =
          described_class.new(type_name) do
            prop :street, Boa::Type::String
          end

        assert_equal(Boa::Type::String.new(:street), subject.properties[:street])
      end
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

  # describe '#==' do
  #   include Support::TypeBehaviour::Equality
  #
  #   it 'is false when object state is equal but does not eql?' do
  #     subject = described_class.new(type_name)
  #     other   = described_class.new(type_name)
  #
  #     assert_equal(subject, other)
  #     refute_operator(subject, :eql?, other)
  #   end
  # end

  # describe '#eql' do
  #   include Support::TypeBehaviour::Eql
  # end

  # describe '#hash' do
  #   include Support::TypeBehaviour::Hash
  # end

  describe '#add_methods' do
    include Support::TypeBehaviour::AddMethods
  end

  describe '#finalize' do
    include Support::TypeBehaviour::Finalize
  end
end
