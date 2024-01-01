# typed: strong
# frozen_string_literal: true

module StrictMatchers
  extend T::Helpers
  extend T::Sig

  requires_ancestor { Minitest::Test }

  Undefined = Minitest::Assertions::UNDEFINED

  sig { params(test: T::Boolean, msg: T.nilable(T.any(String, Proc))).returns(T::Boolean) }
  def assert(test, msg = nil)
    T.let(super, T::Boolean)
  end

  sig { params(exp: T.nilable(Object), act: T.nilable(Object), msg: T.nilable(T.any(String, Proc))).returns(T::Boolean) }
  def assert_equal(exp, act, msg = nil)
    T.let(super, T::Boolean)
  ensure
    raise_with_clean_backtrace('exp and act cannot be nil, use assert_nil(...) instead')        if exp.nil? || act.nil?
    raise_with_clean_backtrace('exp and act are the same object, use assert_same(...) instead') if exp.equal?(act)
  end

  sig { params(exp: T.nilable(Object), act: T.nilable(Object), msg: T.nilable(T.any(String, Proc))).returns(T::Boolean) }
  def refute_same(exp, act, msg = nil)
    T.let(super, T::Boolean)
  ensure
    raise_with_clean_backtrace('exp and act cannot be nil, use assert_nil(...) instead')         if exp.nil? || act.nil?
    raise_with_clean_backtrace('exp and act are the same object, use refute_equal(...) instead') if exp != act
  end

  sig { params(o1: Object, op: Symbol, o2: Object, msg: T.nilable(T.any(String, Proc))).returns(T::Boolean) }
  def assert_operator(o1, op, o2 = Undefined, msg = nil) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Naming/MethodParameterName
    T.let(super, T::Boolean)
  ensure
    raise_with_clean_backtrace('use assert_predicate(...) when testing a predicate') if o2.equal?(Undefined)
  end

  sig { params(o1: Object, op: Symbol, o2: Object, msg: T.nilable(T.any(String, Proc))).returns(T::Boolean) }
  def refute_operator(o1, op, o2 = Undefined, msg = nil) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Naming/MethodParameterName
    T.let(super, T::Boolean)
  ensure
    raise_with_clean_backtrace('use refute_predicate(...) when testing a predicate') if o2.equal?(Undefined)
  end

private

  sig { params(msg: String).returns(T.noreturn) }
  def raise_with_clean_backtrace(msg)
    # Remove all lines outside of the project root
    backtrace = caller
      .lazy
      .select { |line| line.start_with?(ROOT_PATH.to_s)         }
      .reject { |line| line.start_with?(__FILE__)               }
      .map    { |line| ".#{line.delete_prefix(ROOT_PATH.to_s)}" }
      .to_a

    raise(RuntimeError, msg, backtrace)
  end
end
