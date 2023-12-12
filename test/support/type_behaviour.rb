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

      it 'sets the name attribute' do
        assert_equal(type_name, subject.name)
      end

      describe 'with no default option' do
        it 'sets the default attribute to the default' do
          assert_nil(subject.default)
        end
      end

      describe 'with a default option' do
        subject { described_class.new(type_name, default: non_nil_default) }

        describe 'with a non-nil value' do
          it 'sets the default attribute' do
            assert_equal(non_nil_default, subject.default)
          end
        end
      end

      describe 'with no includes option' do
        it 'sets the includes attribute to the default' do
          if default_includes.nil?
            assert_nil(subject.includes)
          else
            assert_equal(default_includes, subject.includes)
          end
        end
      end

      describe 'with an includes option' do
        subject { described_class.new(type_name, includes: []) }

        it 'sets the includes attribute to an empty list' do
          assert_empty(subject.includes)
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
        it 'returns nil' do
          assert_nil(subject.default)
        end
      end
    end

    shared_examples 'Boa::Type#==' do
      cover 'Boa::Equality#=='

      describe 'when the types have the same name and options' do
        it 'returns true' do
          assert_equal(subject, other)
        end
      end

      describe 'when the types have different names and same options' do
        let(:other_name) { :other }

        it 'returns false' do
          refute_equal(subject, other)
        end
      end

      describe 'when the types have the same name and options, but one is subclass' do
        let(:other_class) { Class.new(described_class) }

        it 'returns true' do
          assert_equal(subject, other)
        end
      end

      describe 'when the types have the same name and options, but one is not a subclass' do
        let(:other_class) { Class.new(Boa::Type) }

        it 'returns true' do
          refute_equal(subject, other)
        end
      end

      describe 'when the types have the same name and different options' do
        let(:other_options) { different_options }

        it 'returns false' do
          refute_equal(subject, other)
        end
      end
    end

    shared_examples 'Boa::Type#eql?' do
      cover 'Boa::Equality#eql?'

      describe 'when the types have the same name and options' do
        it 'returns true' do
          assert_operator(subject, :eql?, other)
        end
      end

      describe 'when the types have different names and same options' do
        let(:other_name) { :other }

        it 'returns false' do
          refute_operator(subject, :eql?, other)
        end
      end

      describe 'when the types have the same name and options, but one is subclass' do
        let(:other_class) { Class.new(described_class) }

        it 'returns false' do
          refute_operator(subject, :eql?, other)
        end
      end

      describe 'when the types have the same name and options, but one is not a subclass' do
        let(:other_class) { Class.new(Boa::Type) }

        it 'returns true' do
          refute_operator(subject, :eql?, other)
        end
      end

      describe 'when the types have the same name and different options' do
        let(:other_options) { different_options }

        it 'returns false' do
          refute_operator(subject, :eql?, other)
        end
      end
    end

    shared_examples 'Boa::Type#hash' do
      cover 'Boa::Equality#hash'

      it 'returns an integer' do
        assert_kind_of(Integer, subject.hash)
      end

      it 'returns the same value for equal objects' do
        assert_equal(subject.hash, other.hash)
      end

      it 'returns the different values for different objects' do
        other = described_class.new(other_name, **different_options)

        refute_equal(subject.hash, other.hash)
      end

      it 'returns different values for objects with the same name and options, but one is subclass' do
        subclass = Class.new(described_class)
        other    = subclass.new(type_name, **options)

        refute_equal(subject.hash, other.hash)
      end
    end
  end
end
