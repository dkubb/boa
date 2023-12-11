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
        # assert there is no explict mapping for the class type
        error =
          assert_raises(ArgumentError) do
            described_class[class_type]
          end

        assert_equal("type class for #{class_type} is unknown", error.message)
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
      assert_raises(ArgumentError) do
        described_class[class_type]
      end

      subject

      assert_same(type_class, described_class[class_type])
    end
  end

  describe '.class_type' do
    cover 'Boa::Type.class_type'

    subject { described_class.class_type(class_type) }

    sig { returns(Module) }
    def class_type
      @class_type ||= Class.new
    end

    after do
      # Remove the type class from the registry
      described_class.send(:class_types).delete(class_type) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Style/Send
    end

    it 'returns the type class' do
      assert_same(described_class, subject)
    end

    it 'sets the class type' do
      # assert there is no explict mapping for the class type
      assert_raises(ArgumentError) do
        described_class[class_type]
      end

      subject

      assert_same(described_class, described_class[class_type])
    end
  end

  describe '.inherited' do
    cover 'Boa::Type.inherited'

    subject { Class.new(described_class) }

    sig do
      params(klass: T.class_of(Object), method_name: Symbol, block: T.proc.params(descendant: T.class_of(Boa::Type)).void).void
    end
    def replace_method(klass, method_name, &block)
      original_verbose = $VERBOSE
      $VERBOSE         = nil

      # Replace the singleton method without warnings
      klass.define_singleton_method(method_name, &block)

      $VERBOSE = original_verbose
    end

    it 'set the class types' do
      assert_same(described_class.send(:class_types), subject.send(:class_types)) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Style/Send
    end

    it 'calls super' do
      superclass           = Boa::Type.superclass
      superclass_inherited = superclass.method(:inherited)
      original_inherited   = Boa::Type.method(:inherited)
      inherited            = []

      # Override Boa::Type.inherited
      replace_method(Boa::Type, :inherited) do |descendant|
        inherited << Boa::Type
        original_inherited.call(descendant)
      end

      # Override superclass.inherited
      replace_method(superclass, :inherited) do |descendant|
        inherited << superclass
        superclass_inherited.call(descendant)
      end

      subject

      assert_equal([Boa::Type, superclass], inherited)

      # Restore superclass.inherited
      replace_method(superclass, :inherited, &superclass_inherited)

      # Restore Boa::Type.inherited
      replace_method(Boa::Type, :inherited, &original_inherited)
    end
  end
end
