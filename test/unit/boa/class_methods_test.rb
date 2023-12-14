# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::ClassMethods do
  extend T::Sig

  subject do
    Class.new(T::Struct) do
      extend Boa::ClassMethods

      prop :name,  String
      prop :admin, T::Boolean
    end
  end

  describe '#properties' do
    cover 'Boa::ClassMethods#properties'

    it 'returns the properties' do
      assert_equal({ name: Boa::Type::String.new(:name), admin: Boa::Type::Boolean.new(:admin) }, subject.properties)
    end
  end

  describe '#prop' do
    cover 'Boa::ClassMethods#prop'

    subject do
      Class.new(T::Struct) do
        extend Boa::ClassMethods

        prop :name, String, default: 'Default Name'
      end
    end

    it 'sets the property' do
      subject

      assert_equal({ name: Boa::Type::String.new(:name, default: 'Default Name') }, subject.properties)
    end

    it 'returns self' do
      assert_same(subject, subject.prop(:admin, T::Boolean))
    end

    it 'passes through the default option' do
      assert_same('Default Name', subject.new.name)
    end
  end

  describe '#freeze' do
    cover 'Boa::ClassMethods#freeze'

    before do
      subject.class_eval { @ivar = +'value' }
    end

    it 'freezes the properties' do
      refute_operator(subject.properties, :frozen?)

      subject.freeze

      assert_operator(subject.properties, :frozen?)
    end

    it 'freezes the instance variables' do
      ivar = subject.instance_variable_get(:@ivar)

      refute_operator(ivar, :frozen?)

      subject.freeze

      assert_operator(ivar, :frozen?)
    end

    it 'freezes the class' do
      assert_operator(subject.freeze, :frozen?)
    end

    it 'returns the class' do
      assert_same(subject, subject.freeze)
    end
  end
end
