# typed: false
# frozen_string_literal: true

module Support
  module TypeBehaviour
    extend T::Sig
    extend SharedSetup

    sig { returns(T.class_of(Boa::Type)) }
    def type_class
      @type_class ||= Class.new(described_class)
    end

    sig { returns(Module) }
    def class_type
      @class_type ||= Class.new
    end

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

    shared_examples 'Boa::Type.[]' do
      cover 'Boa::Type.[]'

      subject { described_class[class_type] }

      describe 'when class type is registered' do
        let(:class_type) { String }

        it 'returns the expected type class' do
          assert_same(Boa::Type::String, subject)
        end
      end

      describe 'when class type is not registered' do
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

    shared_examples 'Boa::Type.[]=' do
      cover 'Boa::Type.[]='

      subject { described_class[class_type] = type_class }

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

    shared_examples 'Boa::Type.class_type' do
      cover 'Boa::Type.class_type'

      subject { described_class.class_type(class_type) }

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

    shared_examples 'Boa::Type.inherited' do
      cover 'Boa::Type.inherited'

      subject { Class.new(described_class) }

      it 'set the class types' do
        assert_same(described_class.send(:class_types), subject.send(:class_types)) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Style/Send
      end

      it 'calls super' do
        described_class    = self.described_class
        object_inherited   = Object.method(:inherited)
        original_inherited = described_class.method(:inherited)
        inherited          = []

        # Override described_class.inherited
        replace_method(described_class, :inherited) do |descendant|
          inherited << described_class
          original_inherited.call(descendant)
        end

        # Override Object.inherited
        replace_method(Object, :inherited) do |descendant|
          inherited << Object
          object_inherited.call(descendant)
        end

        subject

        assert_equal([described_class, Object], inherited)

        # Restore Object.inherited
        replace_method(Object, :inherited, &object_inherited)

        # Restore described_class.inherited
        replace_method(described_class, :inherited, &original_inherited)
      end
    end

    shared_examples 'Boa::Type.new' do
      cover 'Boa::Type.new'
      cover 'Boa::Type#initialize'

      describe 'with no default option' do
        let(:options) { {} }

        it 'sets the name attribute' do
          assert_equal(type_name, subject.name)
        end

        it 'sets the default attribute to the default' do
          assert_nil(subject.default)
        end

        it 'freezes the type' do
          assert_operator(subject, :frozen?)
        end
      end

      describe 'with a default option' do
        subject { described_class.new(type_name, default: non_nil_default) }

        describe 'with a non-nil value' do
          it 'sets the name attribute' do
            assert_equal(type_name, subject.name)
          end

          it 'sets the default attribute' do
            assert_equal(non_nil_default, subject.default)
          end

          it 'freezes the type' do
            assert_operator(subject, :frozen?)
          end
        end
      end

      describe 'with no includes option' do
        it 'sets the name attribute' do
          assert_equal(type_name, subject.name)
        end

        it 'sets the includes attribute to the default' do
          if default_includes.nil?
            assert_nil(subject.includes)
          else
            assert_equal(default_includes, subject.includes)
          end
        end

        it 'freezes the type' do
          assert_operator(subject, :frozen?)
        end
      end

      describe 'with an includes option' do
        subject { described_class.new(type_name, includes: []) }

        it 'sets the name attribute' do
          assert_equal(type_name, subject.name)
        end

        it 'sets the includes attribute to an empty list' do
          assert_empty(subject.includes)
        end

        it 'freezes the type' do
          assert_operator(subject, :frozen?)
        end
      end
    end

    shared_examples 'Boa::Type#name' do
      cover 'Boa::Type#name'

      it 'returns the name' do
        assert_same(type_name, subject.name)
      end
    end

    shared_examples 'Boa::Type#includes' do
      cover 'Boa::Type#incldues'

      subject { described_class.new(type_name, includes:) }

      it 'returns the includes' do
        assert_same(includes, subject.includes)
      end
    end

    shared_examples 'Boa::Type#options' do
      cover 'Boa::Type#options'

      subject { described_class.new(type_name, **options) }

      let(:options) { { default: nil } }

      it 'returns the options' do
        assert_equal(options, subject.options)
      end
    end

    shared_examples 'Boa::Type#default' do
      cover 'Boa::Type#default'

      subject { described_class.new(type_name, **options) }

      describe 'with a default option' do
        let(:options) { { default: } }

        it 'returns the default' do
          assert_same(default, subject.default)
        end
      end

      describe 'with no default option' do
        let(:options) { {} }

        it 'returns nil' do
          assert_nil(subject.default)
        end
      end
    end

    shared_examples 'Boa::Type#freeze' do
      cover 'Boa::Type#freeze'

      subject do
        # construct the object directly
        described_class.allocate.tap do |type|
          type.instance_eval do
            @name     = :name
            @includes = nil
            @options  = {}
          end
        end
      end

      it 'freezes the instance variables' do
        ivars =
          subject.instance_variables.to_h do |ivar|
            [ivar, subject.instance_variable_get(ivar)]
          end

        # assert the instance variables are not frozen
        ivars.each_value do |value|
          next if value.nil? || value.instance_of?(Symbol)

          refute_operator(value, :frozen?)
        end

        subject.freeze

        # assert the instance variables are frozen
        ivars.each_value do |value|
          assert_operator(value, :frozen?)
        end
      end

      it 'freezes the type' do
        assert_operator(subject.freeze, :frozen?)
      end

      it 'returns the type' do
        assert_same(subject, subject.freeze)
      end
    end
  end
end
