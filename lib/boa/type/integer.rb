# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # An integer type
    class Integer < self
      Type[::Integer] = self
    end
  end
end
