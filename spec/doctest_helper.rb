# typed: strong
# frozen_string_literal: true

require 'sorbet-runtime'

require 'boa'

extend T::Sig

class Equality
  extend T::Sig
  include Boa::Equality

  sig { void }
  def initialize
    @object_id = T.let(object_id, Integer)
  end
end

sig { returns(Boa::Type) }
def type
  @type ||= T.let(Class.new(Boa::Type).new(:first_name, default: 'Jon'), T.nilable(Boa::Type))
end

sig { returns(T::Class[Boa::Equality]) }
def equality_class
  @equality_class ||= T.let(Equality, T.nilable(T::Class[Boa::Equality]))
end

sig { returns(Boa::Equality) }
def equality_object
  @equality_object ||= T.let(equality_class.new, T.nilable(Boa::Equality))
end

sig { returns(Object) }
def other
  @other ||= T.let(Object.new, T.nilable(Object))
end

YARD::Doctest.configure do |doctest|
  doctest = T.let(doctest, YARD::Doctest)

  doctest.before('Boa::Equality') do
    @other = T.let(equality_class.new, T.nilable(Boa::Equality))
  end

  doctest.before('Boa::Type::Boolean') do
    @type = Boa::Type::Boolean.new(:author)
  end

  doctest.before('Boa::Type::String') do
    @type = Boa::Type::String.new(:first_name)
  end
end
