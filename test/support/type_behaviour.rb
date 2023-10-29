# typed: false
# frozen_string_literal: true

module Support
  module TypeBehaviour
    module New
      extend T::Sig

      sig { params(descendant: Module).void }
      def self.included(descendant)
        descendant.class_eval do
          cover 'Boa::Type#initialize'

          it 'sets the name attribute' do
            assert_equal(type_name, subject.name)
          end

          describe 'with no required option' do
            it 'sets the required attribute to the default' do
              assert_operator(subject, :required)
            end
          end

          describe 'with a required option' do
            subject { described_class.new(type_name, required:) }

            describe 'with a true value' do
              sig { returns(T::Boolean) }
              def required
                true
              end

              it 'sets the required attribute to true' do
                assert_operator(subject, :required)
              end
            end

            describe 'with a false value' do
              sig { returns(T::Boolean) }
              def required
                false
              end

              it 'sets the required attribute to false' do
                refute_operator(subject, :required)
              end
            end
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
            subject { described_class.new(type_name, includes: [true]) }

            it 'sets the includes attribute' do
              assert_equal([true], subject.includes)
            end
          end

          describe 'with no ivar_name option' do
            it 'sets the ivar_name attribute to the default' do
              assert_equal(:"@#{type_name}", subject.ivar_name)
            end
          end

          describe 'with an ivar_name option' do
            subject { described_class.new(type_name, ivar_name: :@custom) }

            it 'sets the ivar_name attribute' do
              assert_equal(:@custom, subject.ivar_name)
            end
          end
        end
      end
    end

    module Init
      extend T::Sig

      sig { params(descendant: Module).void }
      def self.included(descendant)
        descendant.class_eval do
          cover 'Boa::Type#init'

          sig { returns(Object) }
          def object
            @object ||= Object.new
          end

          describe 'when the key exists in the attributes' do
            it 'initializes the object' do
              assert_nil(subject.get(object))

              subject.init(object, subject.name => value)

              assert_same(value, subject.get(object))
            end

            it 'returns self' do
              assert_same(subject, subject.init(object, subject.name => value))
            end
          end

          describe 'when the key does not exist in the attributes' do
            describe 'when there is a default' do
              subject { described_class.new(type_name, default: value) }

              it 'initializes the object with the default' do
                assert_nil(subject.get(object))

                subject.init(object)

                assert_same(value, subject.get(object))
              end

              it 'returns self' do
                assert_same(subject, subject.init(object))
              end
            end

            describe 'when there is no default' do
              it 'does not initialize the object' do
                assert_nil(subject.get(object))

                subject.init(object)

                assert_nil(subject.get(object))
              end

              it 'returns self' do
                assert_same(subject, subject.init(object))
              end
            end
          end
        end
      end
    end

    module Get
      extend T::Sig

      sig { params(descendant: Module).void }
      def self.included(descendant)
        descendant.class_eval do
          cover 'Boa::Type#get'

          sig { returns(Object) }
          def object
            @object ||= Object.new
          end

          describe 'when the instance variable exists in the object' do
            before do
              subject.init(object, subject.name => value)
            end

            it 'returns the value' do
              assert_same(value, subject.get(object))
            end
          end

          describe 'when the instance variable does not exist in the object' do
            it 'returns nil' do
              assert_nil(subject.get(object))
            end
          end
        end
      end
    end

    module Set
      extend T::Sig

      sig { params(descendant: Module).void }
      def self.included(descendant)
        descendant.class_eval do
          cover 'Boa::Type#set'

          sig { returns(Object) }
          def object
            @object ||= Object.new
          end

          sig { returns(Object) }
          def new_value
            @new_value ||= value.dup
          end

          describe 'when the instance variable exists in the object' do
            before do
              subject.init(object, subject.name => value)
            end

            it 'sets the object' do
              assert_same(value, subject.get(object))

              subject.set(object, new_value)

              assert_same(new_value, subject.get(object))
            end

            it 'returns self' do
              assert_same(subject, subject.init(object, subject.name => value))
            end
          end

          describe 'when the instance variable does not exist in the object' do
            it 'returns nil' do
              assert_nil(subject.get(object))

              subject.set(object, new_value)

              assert_same(new_value, subject.get(object))
            end
          end
        end
      end
    end

    module Equality
      extend T::Sig

      sig { params(descendant: Module).void }
      def self.included(descendant)
        descendant.class_eval do
          cover 'Boa::Equality#=='

          describe 'when the types have the same name and options' do
            it 'returns true' do
              assert_equal(subject, other)
            end
          end

          describe 'when the types have different names and same options' do
            sig { returns(Symbol) }
            def other_type_name
              :other
            end

            it 'returns false' do
              refute_equal(subject, other)
            end
          end

          describe 'when the types have the same name and options, but one is subclass' do
            it 'returns true' do
              subclass = Class.new(described_class)

              assert_equal(subject, subclass.new(other_type_name, **other_options))
            end
          end

          describe 'when the types have the same name and options, but one is not a subclass' do
            it 'returns true' do
              sibling_class = Class.new(Boa::Type)

              refute_equal(subject, sibling_class.new(other_type_name, **other_options))
            end
          end

          describe 'when the types have the same name and different options' do
            sig { returns(T::Hash[Symbol, Object]) }
            def other_options
              { required: false }
            end

            it 'returns false' do
              refute_equal(subject, other)
            end
          end
        end
      end
    end

    module Eql
      extend T::Sig

      sig { params(descendant: Module).void }
      def self.included(descendant)
        descendant.class_eval do
          cover 'Boa::Equality#eql?'

          describe 'when the types have the same name and options' do
            it 'returns true' do
              assert_operator(subject, :eql?, other)
            end
          end

          describe 'when the types have different names and same options' do
            sig { returns(Symbol) }
            def other_type_name
              :other
            end

            it 'returns false' do
              refute_operator(subject, :eql?, other)
            end
          end

          describe 'when the types have the same name and different options' do
            sig { returns(T::Hash[Symbol, Object]) }
            def other_options
              { required: false }
            end

            it 'returns false' do
              refute_operator(subject, :eql?, other)
            end
          end

          describe 'when the types have the same name and options, but one is subclass' do
            it 'returns false' do
              subclass = Class.new(described_class)

              refute_operator(subject, :eql?, subclass.new(other_type_name, **other_options))
            end
          end
        end
      end
    end

    module Hash
      extend T::Sig

      sig { params(descendant: Module).void }
      def self.included(descendant)
        descendant.class_eval do
          cover 'Boa::Equality#hash'

          it 'returns an integer' do
            assert_kind_of(Integer, subject.hash)
          end

          it 'returns the same value for equal objects' do
            assert_equal(subject.hash, other.hash)
          end

          it 'returns the different values for different objects' do
            other = described_class.new(type_name, required: false)

            refute_equal(subject.hash, other.hash)
          end

          it 'returns different values for objects with the same name and options, but one is subclass' do
            subclass = Class.new(described_class)
            other    = subclass.new(other_type_name)

            refute_equal(subject.hash, other.hash)
          end
        end
      end
    end

    module AddMethods
      extend T::Sig

      sig { params(descendant: Module).void }
      def self.included(descendant)
        descendant.class_eval do
          cover 'Boa::Type#add_methods'

          sig { returns(T::Class[Boa]) }
          def klass
            @klass ||= Class.new { include Boa }
          end

          before do
            klass.properties[type_name] = subject
          end

          describe 'when the ivar is not nil' do
            it 'adds a reader method' do
              instance = klass.new(type_name => value)

              refute_respond_to(instance, type_name)

              subject.add_methods(klass)

              assert_respond_to(instance, type_name)
              assert_same(value, instance.public_send(type_name))
            end

            it 'returns self' do
              assert_same(subject, subject.add_methods(klass))
            end
          end

          describe 'when the ivar is nil' do
            it 'adds a reader method' do
              instance = klass.new

              refute_respond_to(instance, type_name)

              subject.add_methods(klass)

              assert_respond_to(instance, type_name)
              assert_nil(instance.public_send(type_name))
            end

            it 'returns self' do
              assert_same(subject, subject.add_methods(klass))
            end
          end
        end
      end
    end

    module Finalize
      extend T::Sig

      sig { params(descendant: Module).void }
      def self.included(descendant)
        descendant.class_eval do
          cover 'Boa::Type#finalize'

          it 'freezes the type' do
            refute_operator(subject, :frozen?)

            subject.finalize

            assert_operator(subject, :frozen?)
          end
        end
      end
    end
  end
end
