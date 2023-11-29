# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Util do
  extend T::Sig

  sig { returns(Module) }
  def described_class
    Boa::Util
  end

  describe '.normalize_integer_range' do
    cover 'Boa::Util.normalize_integer_range'

    subject { described_class.normalize_integer_range(range, **options) }

    sig { returns(Range) }
    def range
      Range.new(public_send(:begin), public_send(:end), exclude_end?)
    end

    sig { returns(T::Hash[Symbol, Integer]) }
    def options
      {}
    end

    sig { returns(T.nilable(Integer)) }
    def begin
      1
    end

    sig { returns(T.nilable(Integer)) }
    def end
      10
    end

    describe 'when the range is inclusive' do
      sig { returns(T::Boolean) }
      def exclude_end?
        false
      end

      describe 'when the range begin and end is not nil' do
        it 'returns the expected range' do
          assert_equal(1..10, subject)
        end
      end

      describe 'when the range begin is nil' do
        sig { returns(T.nilable(Integer)) }
        def begin
          nil
        end

        describe 'when there is a begin default' do
          sig { returns(T::Hash[Symbol, Integer]) }
          def options
            { default: 0... }
          end

          it 'returns the expected range' do
            assert_equal(0..10, subject)
          end
        end

        describe 'when there is not a begin default' do
          it 'returns the expected range' do
            assert_equal(..10, subject)
          end
        end
      end

      describe 'when the range end is nil' do
        sig { returns(T.nilable(Integer)) }
        def end
          nil
        end

        describe 'when there is a end default' do
          sig { returns(T::Hash[Symbol, Integer]) }
          def options
            { default: ..11 }
          end

          it 'returns the expected range' do
            assert_equal(1..11, subject)
          end
        end

        describe 'when there is not an end default' do
          it 'returns the expected range' do
            assert_equal(1.., subject)
          end
        end
      end

      describe 'when the range begin and end is nil' do
        sig { returns(T.nilable(Integer)) }
        def begin
          nil
        end

        sig { returns(T.nilable(Integer)) }
        def end
          nil
        end

        describe 'when there is a begin default' do
          sig { returns(T::Hash[Symbol, Integer]) }
          def options
            { default: 0.. }
          end

          it 'returns the expected range' do
            assert_equal(0.., subject)
          end
        end

        describe 'when there is not a begin default' do
          it 'returns the expected range' do
            assert_equal(nil.., subject)
          end
        end

        describe 'when there is a end default' do
          sig { returns(T::Hash[Symbol, Integer]) }
          def options
            { default: ..11 }
          end

          it 'returns the expected range' do
            assert_equal(..11, subject)
          end
        end

        describe 'when there is not an end default' do
          it 'returns the expected range' do
            assert_equal(nil.., subject)
          end
        end
      end
    end

    describe 'when the range is exclusive' do
      sig { returns(T::Boolean) }
      def exclude_end?
        true
      end

      describe 'when the range begin and end is not nil' do
        it 'returns the expected range' do
          assert_equal(1..9, subject)
        end
      end

      describe 'when the range begin is nil' do
        sig { returns(T.nilable(Integer)) }
        def begin
          nil
        end

        describe 'when there is a begin default' do
          sig { returns(T::Hash[Symbol, Integer]) }
          def options
            { default: 0... }
          end

          it 'returns the expected range' do
            assert_equal(0..9, subject)
          end
        end

        describe 'when there is not a begin default' do
          it 'returns the expected range' do
            assert_equal(..9, subject)
          end
        end
      end

      describe 'when the range end is nil' do
        sig { returns(T.nilable(Integer)) }
        def end
          nil
        end

        describe 'when there is a end default' do
          sig { returns(T::Hash[Symbol, Integer]) }
          def options
            { default: ...12 }
          end

          it 'returns the expected range' do
            assert_equal(1..11, subject)
          end
        end

        describe 'when there is not an end default' do
          it 'returns the expected range' do
            assert_equal(1.., subject)
          end
        end
      end

      describe 'when the range begin and end is nil' do
        sig { returns(T.nilable(Integer)) }
        def begin
          nil
        end

        sig { returns(T.nilable(Integer)) }
        def end
          nil
        end

        describe 'when there is a begin default' do
          sig { returns(T::Hash[Symbol, Integer]) }
          def options
            { default: 0... }
          end

          it 'returns the expected range' do
            assert_equal(0.., subject)
          end
        end

        describe 'when there is not a begin default' do
          it 'returns the expected range' do
            assert_equal(nil.., subject)
          end
        end

        describe 'when there is a end default' do
          sig { returns(T::Hash[Symbol, Integer]) }
          def options
            { default: ...12 }
          end

          it 'returns the expected range' do
            assert_equal(..11, subject)
          end
        end

        describe 'when there is not an end default' do
          it 'returns the expected range' do
            assert_equal(nil.., subject)
          end
        end
      end
    end
  end
end
