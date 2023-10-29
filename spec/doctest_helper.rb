# typed: strong
# frozen_string_literal: true

require 'simplecov'
require 'sorbet-runtime'

require 'boa'

extend T::Sig

class Person
  include Boa

  prop :name,  Type::String, default: 'Dan Kubb', length: 1..50
  prop :email, Type::String
  prop :admin, Type::Boolean, default: false

  finalize
end

sig { returns(Boa) }
def instance
  @instance ||= T.assert_type!(Person.new, T.nilable(Person))
end

sig { returns(Boa::Type) }
def type
  @type ||= T.assert_type!(Class.new(Boa::Type).new(:first_name, default: 'Jon'), T.nilable(Boa::Type))
end

sig { returns(T::Class[Boa]) }
def descendant
  @descendant ||= T.assert_type!(Class.new { include Boa }, T.nilable(T::Class[Boa]))
end

sig { returns(T::Class[Boa::Equality]) }
def equality_class
  @equality_class ||=
    Class.new do
      extend T::Sig
      include Boa::Equality

      protected

      sig { override.returns(T::Hash[Symbol, Object]) }
      def object_state
        { object_id: }
      end
    end
end

sig { returns(Boa::Equality) }
def equality_object
  @equality_object ||= T.assert_type!(equality_class.new, T.nilable(Boa::Equality))
end

sig { returns(Object) }
def other
  @other ||= Object.new
end

YARD::Doctest.configure do |doctest|
  doctest.before('Boa::Equality') do
    @other = T.assert_type!(equality_class.new, T.nilable(Boa::Equality))
  end

  doctest.before('Boa::Type::Boolean') do
    @type = Boa::Type::Boolean.new(:author)
  end

  doctest.before('Boa::Type::String') do
    @type = Boa::Type::String.new(:first_name)
  end

  doctest.before do
    @instance = nil
  end
end
