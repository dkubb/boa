# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type do
  extend T::Sig
  include Support::TypeBehaviour

  sig { returns(T.class_of(Boa::Type)) }
  def described_class
    Boa::Type
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
end
