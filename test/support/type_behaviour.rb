# typed: false
# frozen_string_literal: true

module Support
  module TypeBehaviour
    module New
      extend T::Sig

      sig { params(descendant: T.class_of(Minitest::Spec)).void }
      def self.included(descendant)
        descendant.class_eval do
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
      end
    end

    module Equality
      extend T::Sig

      sig { params(descendant: T.class_of(Minitest::Spec)).void }
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
            def other_name
              :other
            end

            it 'returns false' do
              refute_equal(subject, other)
            end
          end

          describe 'when the types have the same name and options, but one is subclass' do
            sig { returns(T.class_of(Boa::Type)) }
            def other_class
              Class.new(described_class)
            end

            it 'returns true' do
              assert_equal(subject, other)
            end
          end

          describe 'when the types have the same name and options, but one is not a subclass' do
            sig { returns(T.class_of(Boa::Type)) }
            def other_class
              Class.new(Boa::Type)
            end

            it 'returns true' do
              refute_equal(subject, other)
            end
          end

          describe 'when the types have the same name and different options' do
            sig { returns(T::Hash[Symbol, Object]) }
            def other_options
              different_options
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

      sig { params(descendant: T.class_of(Minitest::Spec)).void }
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
            def other_name
              :other
            end

            it 'returns false' do
              refute_operator(subject, :eql?, other)
            end
          end

          describe 'when the types have the same name and options, but one is subclass' do
            sig { returns(T.class_of(Boa::Type)) }
            def other_class
              Class.new(described_class)
            end

            it 'returns false' do
              refute_operator(subject, :eql?, other)
            end
          end

          describe 'when the types have the same name and options, but one is not a subclass' do
            sig { returns(T.class_of(Boa::Type)) }
            def other_class
              Class.new(Boa::Type)
            end

            it 'returns true' do
              refute_operator(subject, :eql?, other)
            end
          end

          describe 'when the types have the same name and different options' do
            sig { returns(T::Hash[Symbol, Object]) }
            def other_options
              different_options
            end

            it 'returns false' do
              refute_operator(subject, :eql?, other)
            end
          end
        end
      end
    end

    module Hash
      extend T::Sig

      sig { params(descendant: T.class_of(Minitest::Spec)).void }
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
  end
end
