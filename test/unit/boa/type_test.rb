# typed: strong
# frozen_string_literal: true

require 'test_helper'

require_relative '../boa_test'

module Boa
  class Test
    class Type < Minitest::Test
      extend T::Sig
      include Support::TypeBehaviour::Setup

      parallelize_me!

      sig { override.returns(T.class_of(Boa::Type)) }
      def described_class
        Boa::Type
      end

      class ElementReference < self
        include Support::TypeBehaviour::ElementReference
      end

      class ElementAssignment < self
        include Support::TypeBehaviour::ElementAssignment
      end

      class ClassType < self
        include Support::TypeBehaviour::ClassType
      end

      class Inherited < self
        include Support::TypeBehaviour::Inherited
      end
    end
  end
end
