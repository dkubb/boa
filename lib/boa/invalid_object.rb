# typed: strong
# frozen_string_literal: true

module Boa
  # Abstract class for invalid objects
  class InvalidObject < RuntimeError
    extend T::Sig
    extend T::Helpers
    include InstanceMethods

    abstract!

    # The input that was used to create the object
    #
    # @example
    #   person = Person.new(name: 'Dan Kubb', admin: false)
    #   person.input # => { name: 'Dan Kubb', admin: false }
    #
    # @return [Hash{Symbol => Object}] the input
    #
    # @api public
    sig { returns(T::Hash[Symbol, Object]) }
    attr_reader :input

    # The errors that were found
    #
    # @example
    #   person = Person.new(name: '', admin: false)
    #   person.errors # => { name: ['must be at least 1 character long'] }
    #
    # @return [Hash{Symbol => Array<String>}] the errors
    #
    # @api public
    sig { returns(T::Hash[Symbol, T::Array[String]]) }
    attr_reader :errors

    # Initialize an invalid object
    #
    # @param errors [Hash{Symbol => Array<String>}] the errors
    #
    # @return [InvalidObject] the invalid object
    #
    # @api private
    sig { params(input: T::Hash[Symbol, Object], errors: T::Hash[Symbol, T::Array[String]]).void }
    def initialize(input:, errors:)
      @input  = T.let(Ractor.make_shareable(input,  copy: true), T::Hash[Symbol, Object])
      @errors = T.let(Ractor.make_shareable(errors, copy: true), T::Hash[Symbol, T::Array[String]])

      super("Invalid #{self.class.name} with input: #{input.inspect} and errors: #{errors.inspect}")

      freeze
    end

    # Lookup errors for a property
    #
    # @example
    #   person = Person.new(name: '', admin: false)
    #   person.errors[:name] # => ['must be at least 1 character long']
    #
    # @param property [Symbol] the property
    #
    # @return [Array<String>] the errors
    #
    # @api public
    sig { params(property: Symbol).returns(T::Array[String]) }
    def [](property)
      errors.fetch(property)
    end
  end
end
