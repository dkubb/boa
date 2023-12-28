# typed: strong
# frozen_string_literal: true

module Boa
  # The type of argument to Kernel#raise
  ExceptionType = T.type_alias { T.any(Exception, String) }

  # The result of a computation that may fail
  module Result
    extend T::Generic
    extend T::Sig
    include InstanceMethods

    abstract!

    ValueType = type_member # The type of the success value
    ErrorType = type_member # The type of the failure error

    # The success status
    #
    # @return [Boolean] true if the result is a success
    #
    # @abstract
    # @api private
    sig { abstract.returns(T::Boolean) }
    def success?; end

    # The failure status
    #
    # @return [Boolean] true if the result is a failure
    #
    # @abstract
    # @api private
    sig { abstract.returns(T::Boolean) }
    def failure?; end

    # Returns the result of the block if success, self if failure
    #
    # @yield [value] Passes the success value to the block
    # @yieldparam [Object] value The success value
    # @yieldreturn [Result] The result of the block
    #
    # @return [Result] the result of the block if success, self if failure
    #
    # @abstract
    # @api private
    sig do
      abstract
        .params(
          block: T.proc
            .params(arg0: ValueType)
            .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def and_then(&block) end

    # Returns the result of the block if failure, self if success
    #
    # @yield [error] Passes the failure error to the block
    # @yieldparam [Object] error The failure error
    # @yieldreturn [Result] The result of the block
    #
    # @return [Result] the result of the block if failure, self if success
    #
    # @abstract
    # @api private
    sig do
      abstract
        .params(
          block: T.proc
            .params(arg0: T.all(ErrorType, ExceptionType))
            .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def or_else(&block) end

    # Returns a result with the value mapped by the block if success, self if failure
    #
    # @yield [value] Passes the success value to the block
    # @yieldparam [Object] value The success value
    # @yieldreturn [Object] The mapped value
    #
    # @return [Result] a result with the value mapped by the block if success, self if failure
    #
    # @abstract
    # @api private
    sig do
      abstract
        .params(
          block: T.proc
            .params(arg0: ValueType)
            .returns(ValueType)
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def map(&block) end

    # Returns a result with the error mapped by the block if failure, self if success
    #
    # @yield [error] Passes the failure error to the block
    # @yieldparam [Object] error The failure error
    # @yieldreturn [Object] The mapped error
    #
    # @return [Result] a result with the error mapped by the block if failure, self if success
    #
    # @abstract
    # @api private
    sig do
      abstract
        .params(
          block: T.proc
            .params(arg0: T.all(ErrorType, ExceptionType))
            .returns(T.all(ErrorType, ExceptionType))
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def map_failure(&block) end

    # The unwrapped value if success, raises the error if failure
    #
    # @return [Object] the unwrapped value if success, raises the error if failure
    #
    # @raise [Object] the error if failure
    #
    # @abstract
    # @api private
    sig { abstract.returns(ValueType) }
    def unwrap; end

    # Returns the error if failure, raises Exception if success
    #
    # @return [Object] the error if failure, raises Exception if success
    #
    # @raise [Exception] the exception success
    #
    # @abstract
    # @api private
    sig { abstract.returns(ErrorType) }
    def unwrap_failure; end
  end

  # The result of a computation that succeeded
  class Success
    extend T::Generic
    extend T::Sig
    include Result

    ValueTemplate = type_template # The type of the success value (class methods)
    ErrorTemplate = type_template # The type of the failure error (class methods)

    ValueType = type_member # The type of the success value
    ErrorType = type_member # The type of the failure error

    # Construct a new success result
    #
    # @example
    #   success = Boa::Success.new(42)
    #   success.success? # => true
    #
    # @param _value [Object] The success value
    #
    # @return [Success] a new success result
    #
    # @api public
    sig do
      params(_value: ValueTemplate)
        .returns(Result[ValueTemplate, T.all(ErrorTemplate, ExceptionType)])
    end
    def self.new(_value) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Lint/UselessMethodDefinition
      super
    end

    # The success value
    #
    # @return [Object] the success value
    #
    # @api private
    sig { returns(ValueType) }
    attr_reader :value
    private(:value)

    # Initialize a new success result
    #
    # @param value [Object] The success value
    #
    # @return [Success] a new success result
    #
    # @api private
    sig { params(value: ValueType).void }
    def initialize(value)
      @value = T.let(Ractor.make_shareable(value, copy: true), ValueType)
      freeze
    end

    # The success status
    #
    # @example
    #   success = Boa::Success.new(42)
    #   success.success? # => true
    #
    # @return [Boolean] true
    #
    # @api public
    sig { override.returns(T::Boolean) }
    def success?
      true
    end

    # The failure status
    #
    # @example
    #   success = Boa::Success.new(42)
    #   success.failure? # => false
    #
    # @return [Boolean] false
    #
    # @api public
    sig { override.returns(T::Boolean) }
    def failure?
      false
    end

    # Returns the result of the block
    #
    # @example
    #   success = Boa::Success.new(42)
    #   success.and_then { |value| Boa::Success.new(value + 1) }.unwrap # => 43
    #
    # @yield [value] Passes the success value to the block
    # @yieldparam [Object] value The success value
    # @yieldreturn [Result] The result of the block
    #
    # @return [Result] the result of the block
    #
    # @api public
    sig do
      override
        .params(
          block: T.proc
            .params(arg0: ValueType)
            .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def and_then(&block)
      block.(value)
    end

    # Returns self
    #
    # @example
    #   success = Boa::Success.new(42)
    #   success.or_else { |error| Boa::Failure.new(error + 1) }.unwrap # => 42
    #
    # @yield [error] Passes the failure error to the block
    # @yieldparam [Object] error The failure error
    # @yieldreturn [Result] The result of the block
    #
    # @return [Result] self
    #
    # @api public
    sig do
      override
        .params(
          _block: T.proc
            .params(arg0: T.all(ErrorType, ExceptionType))
            .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def or_else(&_block)
      T.bind(self, Success[ValueType, T.all(ErrorType, ExceptionType)])
    end

    # Returns a result with the value mapped by the block
    #
    # @example
    #   success = Boa::Success.new(42)
    #   success.map { |value| value + 1 }.unwrap # => 43
    #
    # @yield [value] Passes the success value to the block
    # @yieldparam [Object] value The success value
    # @yieldreturn [Object] The mapped value
    #
    # @return [Result] a result with the value mapped by the block
    #
    # @api public
    sig do
      override
        .params(
          block: T.proc
            .params(arg0: ValueType)
            .returns(ValueType)
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def map(&block)
      T.cast(self.class.new(block.(value)), Result[ValueType, T.all(ErrorType, ExceptionType)])
    end

    # Returns self
    #
    # @example
    #   success = Boa::Success.new(42)
    #   success.map_failure { |error| error + 1 }.unwrap # => 42
    #
    # @yield [error] Passes the failure error to the block
    # @yieldparam [Object] error The failure error
    # @yieldreturn [Object] The mapped error
    #
    # @return [Result] self
    #
    # @api public
    sig do
      override
        .params(
          _block: T.proc
            .params(arg0: T.all(ErrorType, ExceptionType))
            .returns(T.all(ErrorType, ExceptionType))
        )
        .returns(Success[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def map_failure(&_block)
      T.bind(self, Success[ValueType, T.all(ErrorType, ExceptionType)])
    end

    # The unwrapped value
    #
    # @example
    #   success = Boa::Success.new(42)
    #   success.unwrap # => 42
    #
    # @return [Object] the unwrapped value
    #
    # @api public
    sig { override.returns(ValueType) }
    def unwrap
      value
    end

    # Raises Exception
    #
    # @example
    #   success = Boa::Success.new(42)
    #   success.unwrap_failure # => raise RuntimeError, 'Cannot unwrap failure from success'
    #
    # @return [void]
    #
    # @raise [RuntimeError]
    #
    # @api public
    sig { override.returns(T.noreturn) }
    def unwrap_failure
      raise('Cannot unwrap failure from success')
    end
  end

  # The result of a computation that failed
  class Failure
    extend T::Generic
    extend T::Sig
    include Result

    ValueTemplate = type_template # The type of the success value (class methods)
    ErrorTemplate = type_template # The type of the failure error (class methods)

    ValueType = type_member # The type of the success value
    ErrorType = type_member # The type of the failure error

    # Construct a new failure result
    #
    # @example
    #   failure = Boa::Failure.new('error')
    #   failure.failure? # => true
    #
    # @param _error [Object] The failure error
    #
    # @return [Failure] a new failure result
    #
    # @api public
    sig do
      params(_error: T.all(ErrorTemplate, ExceptionType))
        .returns(Result[ValueTemplate, T.all(ErrorTemplate, ExceptionType)])
    end
    def self.new(_error) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Lint/UselessMethodDefinition
      super
    end

    # The failure error
    #
    # @return [Object] the failure error
    #
    # @api private
    sig { returns(T.all(ErrorType, ExceptionType)) }
    attr_reader :error
    private(:error)

    # Initialize a new failure result
    #
    # @param error [Object] The failure error
    #
    # @return [Failure] a new failure result
    #
    # @api private
    sig { params(error: T.all(ErrorType, ExceptionType)).void }
    def initialize(error)
      @error = T.let(Ractor.make_shareable(error, copy: true), T.all(ErrorType, ExceptionType))
      freeze
    end

    # The success status
    #
    # @example
    #   failure = Boa::Failure.new('error')
    #   failure.success? # => false
    #
    # @return [Boolean] true
    #
    # @api public
    sig { override.returns(T::Boolean) }
    def success?
      false
    end

    # The failure status
    #
    # @example
    #   failure = Boa::Failure.new('error')
    #   failure.failure? # => true
    #
    # @return [Boolean] true
    #
    # @api public
    sig { override.returns(T::Boolean) }
    def failure?
      true
    end

    # Returns self
    #
    # @example
    #   failure = Boa::Failure.new('error')
    #   failure.and_then { |value| Boa::Success.new(value + 1) }.unwrap_failure # => 'error'
    #
    # @yield [value] Passes the success value to the block
    # @yieldparam [Object] value The success value
    # @yieldreturn [Result] The result of the block
    #
    # @return [Result] self
    #
    # @api public
    sig do
      override
        .params(
          _block: T.proc
            .params(arg0: ValueType)
            .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def and_then(&_block)
      T.bind(self, Failure[ValueType, T.all(ErrorType, ExceptionType)])
    end

    # Returns the result of the block
    #
    # @example
    #   failure = Boa::Failure.new('error')
    #   failure.or_else { |error| Boa::Failure.new("new #{error}") }.unwrap_failure # => 'new error'
    #
    # @yield [error] Passes the failure error to the block
    # @yieldparam [Object] error The failure error
    # @yieldreturn [Result] The result of the block
    #
    # @return [Result] the result of the block
    #
    # @api public
    sig do
      override
        .params(
          block: T.proc
            .params(arg0: T.all(ErrorType, ExceptionType))
            .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def or_else(&block)
      block.(error)
    end

    # Returns self
    #
    # @example
    #   failure = Boa::Failure.new('error')
    #   failure.map { |value| value + 1 }.unwrap_failure # => 'error'
    #
    # @yield [value] Passes the success value to the block
    # @yieldparam [Object] value The success value
    # @yieldreturn [Object] The mapped value
    #
    # @return [Result] self
    #
    # @api public
    sig do
      override
        .params(
          _block: T.proc
            .params(arg0: ValueType)
            .returns(ValueType)
        )
        .returns(Failure[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def map(&_block)
      T.bind(self, Failure[ValueType, T.all(ErrorType, ExceptionType)])
    end

    # Returns a result with the error mapped by the block
    #
    # @example
    #   failure = Boa::Failure.new('error')
    #   failure.map_failure { |error| "new #{error}" }.unwrap_failure # => 'new error'
    #
    # @yield [error] Passes the failure error to the block
    # @yieldparam [Object] error The failure error
    # @yieldreturn [Object] The mapped error
    #
    # @return [Result] a result with the error mapped by the block
    #
    # @api public
    sig do
      override
        .params(
          block: T.proc
            .params(arg0: T.all(ErrorType, ExceptionType))
            .returns(T.all(ErrorType, ExceptionType))
        )
        .returns(Result[ValueType, T.all(ErrorType, ExceptionType)])
    end
    def map_failure(&block)
      T.cast(self.class.new(block.(error)), Result[ValueType, T.all(ErrorType, ExceptionType)])
    end

    # Raises the error
    #
    # @example
    #   failure = Boa::Failure.new('error')
    #   failure.unwrap # => raise RuntimeError, 'error'
    #
    # @return [void]
    #
    # @raise [Object] the error
    #
    # @api public
    sig { override.returns(T.noreturn) }
    def unwrap
      raise(error)
    end

    # Returns the error
    #
    # @example
    #   failure = Boa::Failure.new('error')
    #   failure.unwrap_failure # => 'error'
    #
    # @return [Object] the error
    #
    # @api public
    sig { override.returns(ErrorType) }
    def unwrap_failure
      error
    end
  end
end
