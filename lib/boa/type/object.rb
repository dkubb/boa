# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # An object type
    class Object < self
      include Boa::ModelMethods

      sig { params(name: Symbol, required: T::Boolean, options: ::Object, block: T.nilable(T.proc.bind(Object).void)).void }
      def initialize(name, required: true, **options, &block)
        super(name, required:, **options)

        instance_eval(&block) if block
      end
    end
  end
end
