# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Type do
  extend T::Sig

  sig { returns(T.class_of(Boa::Type)) }
  def described_class
    Boa::Type
  end

  describe '.[]' do
    cover 'Boa::Type.[]'

    subject { described_class[class_type] }

    describe 'when class type is registered' do
      sig { returns(Module) }
      def class_type
        String
      end

      it 'returns the expected type class' do
        assert_same(Boa::Type::String, subject)
      end
    end

    describe 'when class type is not registered' do
      sig { returns(Module) }
      def class_type
        @class_type ||= Class.new
      end

      it 'returns the default type class' do
        assert_same(Boa::Type::Object, subject)
      end
    end
  end

  describe '.[]=' do
    cover 'Boa::Type.[]='

    subject { described_class[class_type] = type_class }

    sig { returns(Module) }
    def class_type
      @class_type ||= Class.new
    end

    sig { returns(T.class_of(Boa::Type)) }
    def type_class
      @type_class ||= Class.new(described_class)
    end

    after do
      # Remove the type class from the registry
      described_class.send(:class_types).delete(class_type) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Style/Send
    end

    it 'sets the class type' do
      # assert there is no explict mapping for the class type
      assert_same(Boa::Type::Object, described_class[class_type])

      subject

      assert_same(type_class, described_class[class_type])
    end
  end
end
