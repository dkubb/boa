# typed: false
# frozen_string_literal: true

require 'test_helper'

describe Boa::Util do
  extend T::Sig

  let(:described_class) { Boa::Util }

  describe '.normalize_integer_range' do
    cover 'Boa::Util.normalize_integer_range'

    subject { described_class.normalize_integer_range(range, **options) }

    let(:range)   { Range.new(public_send(:begin), public_send(:end), exclude_end?) }
    let(:options) { {}                                                              }
    let(:begin)   { 1                                                               }
    let(:end)     { 10                                                              }

    describe 'when the range is inclusive' do
      let(:exclude_end?) { false }

      describe 'when the range begin and end is not nil' do
        it 'returns the expected range' do
          assert_equal(1..10, subject)
        end
      end

      describe 'when the range begin is nil' do
        let(:begin) { nil }

        describe 'when there is a begin default' do
          let(:options) { { default: 0... } }

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
        let(:end) { nil }

        describe 'when there is a end default' do
          let(:options) { { default: ..11 } }

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
        let(:begin) { nil }
        let(:end)   { nil }

        describe 'when there is a begin default' do
          let(:options) { { default: 0.. } }

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
          let(:options) { { default: ..11 } }

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
      let(:exclude_end?) { true }

      describe 'when the range begin and end is not nil' do
        it 'returns the expected range' do
          assert_equal(1..9, subject)
        end
      end

      describe 'when the range begin is nil' do
        let(:begin) { nil }

        describe 'when there is a begin default' do
          let(:options) { { default: 0... } }

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
        let(:end) { nil }

        describe 'when there is a end default' do
          let(:options) { { default: ...12 } }

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
        let(:begin) { nil }
        let(:end)   { nil }

        describe 'when there is a begin default' do
          let(:options) { { default: 0... } }

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
          let(:options) { { default: ...12 } }

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
