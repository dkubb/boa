# typed: strong
# frozen_string_literal: true

module Boa
  class Type
    # An object type
    class Object < self
      include Boa::ModelMethods

      EMPTY_HASH = {}.freeze
      private_constant(:EMPTY_HASH)

      sig { returns(ModelMethods) }
      attr_reader :model

      sig { params(name: Symbol, required: T::Boolean, options: ::Object, block: T.nilable(T.proc.bind(Object).void)).void }
      def initialize(name, required: true, **options, &block)
        @model =
          Class.new do
            include Boa

            instance_exec(self, &block) if block

            sig { params(other: T.self_type).returns(T::Boolean) }
            def ==(other)
              if other.is_a?(Hash)
                super(self.class.new(**other))
              else
                super(other)
              end
            end

            sig { returns(Integer) }
            def hash
              T.let(object_state.hash, Integer)
            end
          end

        super(name, required:, **options)
      end

      sig { returns(T::Hash[Symbol, Type]) }
      def properties
        model.properties
      end

      sig { params(instance: ::Object, attributes: ::Object).returns(T.self_type) }
      def init(instance, **attributes)
        attrs = attributes.fetch(name) { default }
        return self unless attrs

        set(instance, model.new(**attrs || EMPTY_HASH))
      end

      # TODO: finalize should finalize the model too
    end
  end
end
