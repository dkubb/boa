# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # An object type
    class Object < self
      class_type(::Object)
    end
  end
end
