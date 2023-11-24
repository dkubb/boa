# typed: strong
# frozen_string_literal: true

require 'simplecov'
require 'sorbet-runtime'

require 'boa'

extend T::Sig

class Person < T::Struct
  include Boa

  prop :name,  String, default: 'Dan Kubb', length: 1..50
  prop :email, String
  prop :admin, T::Boolean, default: false
end

sig { returns(Boa) }
def instance
  @instance ||= T.assert_type!(Person.new(email: '', admin: true), T.nilable(Person))
end

sig { returns(Boa::Type) }
def type
  @type ||= T.assert_type!(Class.new(Boa::Type).new(:first_name, default: 'Jon'), T.nilable(Boa::Type))
end

sig { returns(T::Class[Boa]) }
def descendant
  @descendant ||= T.assert_type!(Class.new(T::Struct) { include Boa }, T.nilable(T::Class[Boa]))
end

sig { returns(T.class_of(Boa::Equality)) }
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
