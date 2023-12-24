# typed: strong
# frozen_string_literal: true

require 'sorbet-runtime'

require 'boa'

extend T::Sig

class InstanceMethods
  extend T::Sig
  include Boa::InstanceMethods

  sig { void }
  def initialize
    @object_id = T.let(object_id, Integer)
  end
end

sig { returns(Boa::Type) }
def type
  @type ||= T.let(Class.new(Boa::Type).new(:first_name, default: 'Jon'), T.nilable(Boa::Type))
end

sig { returns(T::Class[Boa::InstanceMethods]) }
def klass
  @klass ||= T.let(InstanceMethods, T.nilable(T::Class[Boa::InstanceMethods]))
end

sig { returns(Boa::InstanceMethods) }
def instance
  @instance ||= T.let(klass.new, T.nilable(Boa::InstanceMethods))
end

sig { returns(Object) }
def other
  @other ||= T.let(Object.new, T.nilable(Object))
end

YARD::Doctest.configure do |doctest|
  doctest = T.let(doctest, YARD::Doctest)

  doctest.before('Boa::InstanceMethods') do
    @other = T.let(klass.new, T.nilable(Boa::InstanceMethods))
  end

  doctest.before('Boa::Type::Boolean') do
    @type = Boa::Type::Boolean.new(:author)
  end

  doctest.before('Boa::Type::String') do
    @type = Boa::Type::String.new(:first_name)
  end
end
