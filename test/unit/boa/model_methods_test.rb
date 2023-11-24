# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::ModelMethods do
  extend T::Sig

  subject do
    Class.new do
      extend Boa::ModelMethods

      prop :name, Boa::Type::String
    end
  end

  describe '#inherited' do
    cover 'Boa::ModelMethods#inherited'

    it 'copies the properties' do
      subclass = Class.new(subject)

      assert_equal(subject.properties, subclass.properties)
      refute_same(subject.properties, subclass.properties)
    end

    it 'calls the superclass inherited method' do
      called_with  = nil

      subject.singleton_class.superclass.define_method(:inherited) do |descendant|
        called_with = descendant
      end

      subclass = Class.new(subject)

      assert_same(subclass, called_with)
    end
  end

  describe '#properties' do
    cover 'Boa::ModelMethods#properties'

    it 'returns the properties' do
      assert_equal({ name: Boa::Type::String.new(:name) }, subject.properties)
    end
  end

  describe '#prop' do
    cover 'Boa::ModelMethods#prop'

    sig { returns(T::Hash[Symbol, Object]) }
    def options
      { required: false, default: false }
    end

    it 'sets the property' do
      subject.prop(:admin, Boa::Type::Boolean, **options)

      assert_equal({ name: Boa::Type::String.new(:name), admin: Boa::Type::Boolean.new(:admin, **options) }, subject.properties)
    end

    it 'returns self' do
      assert_same(subject, subject.prop(:admin, Boa::Type::Boolean, **options))
    end
  end

  describe '#finalize' do
    cover 'Boa::ModelMethods#finalize'

    it 'adds the methods to the class' do
      refute_respond_to(subject.new, :name)

      subject.finalize

      assert_respond_to(subject.new, :name)
    end

    it 'finalizes the types' do
      finalized = false

      subject
        .properties
        .fetch(:name)
        .define_singleton_method(:finalize) { finalized = true }

      refute(finalized)

      subject.finalize

      assert(finalized)
    end

    it 'freezes the class' do
      refute_operator(subject, :frozen?)

      subject.finalize

      assert_operator(subject, :frozen?)
    end

    it 'returns the class' do
      assert_same(subject, subject.finalize)
    end
  end

  describe '#freeze' do
    cover 'Boa::ModelMethods#freeze'

    before do
      subject.class_eval { @ivar = +'value' }
    end

    it 'freezes type of each property' do
      type = subject.properties.fetch(:name)

      refute_operator(type, :frozen?)

      subject.freeze

      assert_operator(type, :frozen?)
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
