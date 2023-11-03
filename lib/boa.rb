# typed: strong
# frozen_string_literal: true

require 'ice_nine'
require 'sorbet-runtime'

require_relative 'boa/equality'
require_relative 'boa/model_methods'
require_relative 'boa/type'
require_relative 'boa/type/object'
require_relative 'boa/type/boolean'
require_relative 'boa/type/integer'
require_relative 'boa/type/string'
require_relative 'boa/version'

# The Boa base module
module Boa
  extend T::Sig
  extend T::Helpers
  include Equality

  # The error raised when an unknown attribute is provided
  class UnknownAttributeError < ArgumentError
    extend T::Sig

    # Initialize the error
    #
    # @param unknown [Array<Symbol>] the unknown attributes
    #
    # @return [void]
    #
    # @api private
    sig { params(unknown: T::Array[Symbol]).void }
    def initialize(unknown)
      super("Unknown attributes: #{unknown.sort.join(', ')}")
    end
  end

  mixes_in_class_methods(ModelMethods)

  abstract!

  # Initialize the object
  #
  # @example
  #   person = Person.new(name: 'Dan')
  #   person.class  # => Person
  #   person.name   # => 'Dan'
  #
  # @param attributes [Hash{Symbol => Object}] the attributes to initialize with
  #
  # @return [void]
  #
  # @api public
  sig { params(attributes: Object).void }
  def initialize(**attributes)
    assert_known_attributes(**attributes)

    model.properties.each_value do |type|
      type.init(T.bind(self, Object), **attributes)
    end
  end

  private

  # The model of the object
  #
  # @return [ModelMethods] the model of the object
  #
  # @api private
  sig { returns(ModelMethods) }
  def model
    # self.class extends the class methods module
    T.let(T.unsafe(self.class), ModelMethods) # rubocop:disable Style/DisableCopsWithinSourceCodeDirective,Sorbet/ForbidTUnsafe
  end

  # Assert that the attributes are known
  #
  # @param attributes [Hash{Symbol => Object}] the attributes to check
  #
  # @return [void]
  #
  # @api private
  sig { params(attributes: Object).void }
  def assert_known_attributes(**attributes)
    unknown = attributes.keys - model.properties.keys
    raise(UnknownAttributeError, unknown) if unknown.any?
  end
end
