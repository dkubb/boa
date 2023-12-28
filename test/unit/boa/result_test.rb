# typed: strong
# frozen_string_literal: true

require 'test_helper'

module Boa
  class Test
    module ResultBehaviour
      extend T::Helpers
      extend T::Sig

      requires_ancestor { Minitest::Test }

      abstract!

      sig { abstract.returns(T::Class[Boa::Result[String, String]]) }
      def described_class; end

      sig { abstract.void }
      def test_new_immutable_input; end

      sig { abstract.void }
      def test_new_mutable_input; end

      sig { abstract.void }
      def test_success; end

      sig { abstract.void }
      def test_failure; end

      sig { abstract.void }
      def test_and_then; end

      sig { abstract.void }
      def test_or_else; end

      sig { abstract.void }
      def test_and_then_or_else; end

      sig { abstract.void }
      def test_or_else_and_then; end

      sig { abstract.void }
      def test_map; end

      sig { abstract.void }
      def test_map_failure; end

      sig { abstract.void }
      def test_map_map_failure; end

      sig { abstract.void }
      def test_unwrap; end

      sig { abstract.void }
      def test_unwrap_failure; end

      # sig { abstract.void }
      # def test_deconstruct
    end

    class Success < Minitest::Test
      extend T::Sig
      include Support::InstanceMethodsBehaviour::Setup

      sig { override.returns(T.class_of(Boa::Success)) }
      def described_class
        Boa::Success
      end

      sig { override.returns(Boa::Success[String, String]) }
      def state_inequality
        @state_inequality ||= T.let(Boa::Success[String, String].new('bar'), T.nilable(Boa::Success[String, String]))
      end

      sig { override.params(klass: T::Class[T.untyped]).returns(T.untyped) }
      def new_object(klass)
        raise(ArgumentError, "klass must be a Boa::Success, but was #{klass}") unless klass <= Boa::Success

        klass.new(value)
      end

      sig { returns(String) }
      def value
        @value ||= T.let(+'foo', T.nilable(String))
      end

      class ResultMethods < self # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Metrics/ClassLength
        extend MutantCoverage
        include ResultBehaviour

        cover('Boa::Success*')

        sig { override.returns(T.class_of(Boa::Success)) }
        def described_class
          Boa::Success
        end

        sig { override.void }
        def test_new_immutable_input
          value.freeze

          subject   = described_class.new(value)
          unwrapped = subject.unwrap

          assert_same(value, unwrapped)
          assert_operator(subject, :frozen?)
          assert_operator(unwrapped, :frozen?)
        end

        sig { override.void }
        def test_new_mutable_input
          subject   = described_class.new(value)
          unwrapped = subject.unwrap

          refute_same(value, unwrapped)
          assert_equal(value, unwrapped)
          assert_operator(subject, :frozen?)
          assert_operator(unwrapped, :frozen?)
        end

        sig { override.void }
        def test_success
          subject = described_class.new(value)

          assert_predicate(subject, :success?)
        end

        sig { override.void }
        def test_failure
          subject = described_class.new(value)

          refute_nil(subject.failure?)
          refute_predicate(subject, :failure?)
        end

        sig { override.void }
        def test_and_then
          subject = described_class.new(value)

          result = subject
            .and_then { |value| Boa::Success.new("#{value}, and then")  }
            .and_then { |value| Boa::Success.new("#{value}, and again") }

          unwrapped = result.unwrap

          assert_instance_of(described_class, result)
          assert_equal('foo, and then, and again', unwrapped)
        end

        sig { override.void }
        def test_or_else
          subject = described_class.new(value)

          result = subject
            .or_else { raise('unreacheable')      }
            .or_else { raise('also unreacheable') }

          assert_same(subject, result)
        end

        sig { override.void }
        def test_and_then_or_else
          subject = described_class.new(value)

          result = subject
            .and_then { |value| Boa::Success.new("#{value}, and then")  }
            .or_else  { raise('unreacheable')                           }
            .and_then { |value| Boa::Success.new("#{value}, and again") }
            .or_else  { raise('also unreacheable')                      }

          unwrapped = result.unwrap

          assert_instance_of(described_class, result)
          assert_equal('foo, and then, and again', unwrapped)
        end

        sig { override.void }
        def test_or_else_and_then
          subject = described_class.new(value)

          result = subject
            .or_else  { raise('unreacheable')                           }
            .and_then { |value| Boa::Success.new("#{value}, and then")  }
            .or_else  { raise('also unreacheable')                      }
            .and_then { |value| Boa::Success.new("#{value}, and again") }

          unwrapped = result.unwrap

          assert_instance_of(described_class, result)
          assert_equal('foo, and then, and again', unwrapped)
        end

        sig { override.void }
        def test_map
          subject = described_class.new(value)

          result = subject
            .map { |value| "#{value}, and then"  }
            .map { |value| "#{value}, and again" }

          unwrapped = result.unwrap

          assert_instance_of(described_class, result)
          assert_equal('foo, and then, and again', unwrapped)
        end

        sig { override.void }
        def test_map_failure
          subject = described_class.new(value)

          result = subject
            .map_failure { raise('unreacheable')      }
            .map_failure { raise('also unreacheable') }

          assert_same(subject, result)
        end

        sig { override.void }
        def test_map_map_failure
          subject = described_class.new(value)

          result = subject
            .map         { |value| "#{value}, and then"  }
            .map_failure { raise('unreacheable')         }
            .map         { |value| "#{value}, and again" }
            .map_failure { raise('also unreacheable')    }

          unwrapped = result.unwrap

          assert_instance_of(described_class, result)
          assert_equal('foo, and then, and again', unwrapped)
        end

        sig { override.void }
        def test_unwrap
          value.freeze

          subject   = described_class.new(value)
          unwrapped = subject.unwrap

          assert_same(value, unwrapped)
        end

        sig { override.void }
        def test_unwrap_failure
          subject = described_class.new(value)

          exception = T.let(
            assert_raises(RuntimeError) { subject.unwrap_failure },
            RuntimeError
          )

          assert_equal('Cannot unwrap failure from success', exception.message)
        end
      end

      class Equality < self
        include Support::InstanceMethodsBehaviour::Equality
      end

      class Eql < self
        include Support::InstanceMethodsBehaviour::Eql
      end

      class Hash < self
        include Support::InstanceMethodsBehaviour::Hash
      end

      class DeconstructKeys < self
        include Support::InstanceMethodsBehaviour::DeconstructKeys

        sig { override.returns(T::Hash[Symbol, ::Object]) }
        def expected_object_state
          { value: }
        end
      end

      class Deconstruct < self
        include Support::InstanceMethodsBehaviour::Deconstruct

        sig { override.returns(T::Hash[Symbol, ::Object]) }
        def expected_object_state
          { value: }
        end
      end
    end

    class Failure < Minitest::Test
      extend T::Sig
      include Support::InstanceMethodsBehaviour::Setup

      sig { override.returns(T.class_of(Boa::Failure)) }
      def described_class
        Boa::Failure
      end

      sig { override.returns(Boa::Failure[String, String]) }
      def state_inequality
        @state_inequality ||= T.let(Boa::Failure[String, String].new('other'), T.nilable(Boa::Failure[String, String]))
      end

      sig { override.params(klass: T::Class[T.untyped]).returns(T.untyped) }
      def new_object(klass)
        raise(ArgumentError, "klass must be a Boa::Failure, but was #{klass}") unless klass <= Boa::Failure

        klass.new(error)
      end

      sig { returns(ExceptionType) }
      def error
        @error ||= T.let(+'error', T.nilable(ExceptionType))
      end

      class ResultMethods < self # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Metrics/ClassLength
        extend MutantCoverage
        include ResultBehaviour

        cover('Boa::Failure*')

        sig { override.returns(T.class_of(Boa::Failure)) }
        def described_class
          Boa::Failure
        end

        sig { override.void }
        def test_new_immutable_input
          error.freeze

          subject   = described_class.new(error)
          unwrapped = subject.unwrap_failure

          assert_same(error, unwrapped)
          assert_operator(subject, :frozen?)
          assert_operator(unwrapped, :frozen?)
        end

        sig { override.void }
        def test_new_mutable_input
          subject   = described_class.new(error)
          unwrapped = subject.unwrap_failure

          refute_same(error, unwrapped)
          assert_equal(error, unwrapped)
          assert_operator(subject, :frozen?)
          assert_operator(unwrapped, :frozen?)
        end

        sig { override.void }
        def test_success
          subject = described_class.new(error)

          refute_nil(subject.success?)
          refute_predicate(subject, :success?)
        end

        sig { override.void }
        def test_failure
          subject = described_class.new(error)

          assert_predicate(subject, :failure?)
        end

        sig { override.void }
        def test_and_then
          subject = described_class.new(error)
          result  = subject
            .and_then { raise('unreacheable')      }
            .and_then { raise('also unreacheable') }

          assert_same(subject, result)
        end

        sig { override.void }
        def test_or_else
          subject = described_class.new(error)

          result = subject
            .or_else { |error| Boa::Failure.new("#{error}, or else")  }
            .or_else { |error| Boa::Failure.new("#{error}, or again") }

          unwrapped = result.unwrap_failure

          assert_instance_of(described_class, result)
          assert_equal('error, or else, or again', unwrapped)
        end

        sig { override.void }
        def test_and_then_or_else
          subject = described_class.new(error)

          result = subject
            .and_then { raise('unreacheable')                          }
            .or_else  { |error| Boa::Failure.new("#{error}, or else")  }
            .and_then { raise('also unreacheable')                     }
            .or_else  { |error| Boa::Failure.new("#{error}, or again") }

          unwrapped = result.unwrap_failure

          assert_instance_of(described_class, result)
          assert_equal('error, or else, or again', unwrapped)
        end

        sig { override.void }
        def test_or_else_and_then
          subject = described_class.new(error)

          result = subject
            .or_else  { |error| Boa::Failure.new("#{error}, or else")  }
            .and_then { raise('unreacheable')                          }
            .or_else  { |error| Boa::Failure.new("#{error}, or again") }
            .and_then { raise('also unreacheable')                     }

          unwrapped = result.unwrap_failure

          assert_instance_of(described_class, result)
          assert_equal('error, or else, or again', unwrapped)
        end

        sig { override.void }
        def test_map
          subject = described_class.new(error)

          result = subject
            .map { raise('unreacheable')      }
            .map { raise('also unreacheable') }

          assert_same(subject, result)
        end

        sig { override.void }
        def test_map_failure
          subject = described_class.new(error)

          result = subject
            .map_failure { |error| "#{error}, and then"  }
            .map_failure { |error| "#{error}, and again" }

          unwrapped = result.unwrap_failure

          assert_instance_of(described_class, result)
          assert_equal('error, and then, and again', unwrapped)
        end

        sig { override.void }
        def test_map_map_failure
          subject = described_class.new(error)

          result = subject
            .map_failure { |error| "#{error}, and then"  }
            .map         { raise('unreacheable')         }
            .map_failure { |error| "#{error}, and again" }
            .map         { raise('also unreacheable')    }

          unwrapped = result.unwrap_failure

          assert_instance_of(described_class, result)
          assert_equal('error, and then, and again', unwrapped)
        end

        sig { override.void }
        def test_unwrap
          subject = described_class.new(error)

          exception = T.let(
            assert_raises(RuntimeError) { subject.unwrap },
            RuntimeError
          )

          assert_equal('error', exception.message)
        end

        sig { override.void }
        def test_unwrap_failure
          error.freeze

          subject   = described_class.new(error)
          unwrapped = subject.unwrap_failure

          assert_same(error, unwrapped)
        end
      end

      class Equality < self
        include Support::InstanceMethodsBehaviour::Equality
      end

      class Eql < self
        include Support::InstanceMethodsBehaviour::Eql
      end

      class Hash < self
        include Support::InstanceMethodsBehaviour::Hash
      end

      class DeconstructKeys < self
        include Support::InstanceMethodsBehaviour::DeconstructKeys

        sig { override.returns(T::Hash[Symbol, ::Object]) }
        def expected_object_state
          { error: }
        end
      end

      class Deconstruct < self
        include Support::InstanceMethodsBehaviour::Deconstruct

        sig { override.returns(T::Hash[Symbol, ::Object]) }
        def expected_object_state
          { error: }
        end
      end
    end
  end
end
