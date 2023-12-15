# typed: false
# frozen_string_literal: true

module Support
  module EqualityBehaviour
    extend SharedSetup

    shared_examples 'Boa::Equality#==' do
      cover 'Boa::Equality#=='

      describe 'when the objects are the same' do
        it 'returns true' do
          assert_equal(subject, subject)
          assert_same(subject, subject)
        end
      end

      describe 'when the objects have similar state' do
        it 'returns true' do
          assert_equal(subject, other)
          refute_same(subject, other)
        end
      end

      describe 'when the objects have similar state, but the other is a subclass' do
        let(:other_class) { Class.new(described_class) }

        it 'returns true' do
          assert_equal(subject, other)
          refute_same(subject, other)
        end
      end

      describe 'when the objects have different classes' do
        before do
          # Redefine the described_class and other_class methods
          # to return different classes.
          described_class = Class.new(self.described_class)
          other_class     = Class.new(self.described_class)

          define_singleton_method(:described_class) { described_class }
          define_singleton_method(:other_class)     { other_class     }
        end

        it 'returns false' do
          refute_equal(subject, other)
        end
      end

      describe 'when the objects have different state' do
        it 'returns false' do
          refute_equal(subject, different_state)
        end
      end

      describe 'when the object states are similar but not equal' do
        it 'returns true' do
          # Only some types differ between #== and #eql?
          return unless respond_to?(:not_eql_state)

          assert_equal(subject, not_eql_state)
          refute_operator(subject, :eql?, not_eql_state)
        end
      end
    end

    shared_examples 'Boa::Equality#eql?' do
      cover 'Boa::Equality#eql?'

      describe 'when the objects are the same' do
        it 'returns true' do
          assert_operator(subject, :eql?, subject)
          assert_same(subject, subject)
        end
      end

      describe 'when the objects have similar state' do
        it 'returns true' do
          assert_operator(subject, :eql?, other)
          refute_same(subject, other)
        end
      end

      describe 'when the objects have similar state, but the other is a subclass' do
        let(:other_class) { Class.new(described_class) }

        it 'returns false' do
          refute_operator(subject, :eql?, other)
        end
      end

      describe 'when the objects have different classes' do
        before do
          # Redefine the described_class and other_class methods
          # to return different classes.
          described_class = Class.new(self.described_class)
          other_class     = Class.new(self.described_class)

          define_singleton_method(:described_class) { described_class }
          define_singleton_method(:other_class)     { other_class     }
        end

        it 'returns false' do
          refute_operator(subject, :eql?, other)
        end
      end

      describe 'when the objects have different state' do
        it 'returns false' do
          refute_operator(subject, :eql?, different_state)
        end
      end

      describe 'when the object states are similar but not equal' do
        it 'returns false' do
          refute_operator(subject, :eql?, not_eql_state) if respond_to?(:not_eql_state)
        end
      end
    end

    shared_examples 'Boa::Equality#hash' do
      cover 'Boa::Equality#hash'

      describe 'when the objects are the same' do
        it 'returns the same hash' do
          assert_same(subject.hash, subject.hash)
        end
      end

      describe 'when the objects have similar state' do
        it 'returns the same hash' do
          assert_same(subject.hash, other.hash)
        end
      end

      describe 'when the objects have similar state, but the other is a subclass' do
        let(:other_class) { Class.new(described_class) }

        it 'returns different hashes' do
          refute_same(subject.hash, other.hash)
        end
      end

      describe 'when the objects have different classes' do
        before do
          # Redefine the described_class and other_class methods
          # to return different classes.
          described_class = Class.new(self.described_class)
          other_class     = Class.new(self.described_class)

          define_singleton_method(:described_class) { described_class }
          define_singleton_method(:other_class)     { other_class     }
        end

        it 'returns different hashes' do
          refute_same(subject.hash, other.hash)
        end
      end

      describe 'when the objects have different state' do
        it 'returns different hashes' do
          refute_same(subject.hash, different_state.hash)
        end
      end

      describe 'when the object states are similar but not equal' do
        it 'returns false' do
          refute_same(subject.hash, not_eql_state.hash) if respond_to?(:not_eql_state)
        end
      end
    end
  end
end
