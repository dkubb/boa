# typed: strong
# frozen_string_literal: true

module Support
  module SharedSetup
    extend T::Helpers
    extend T::Sig

    requires_ancestor { T.class_of(Minitest::Spec) }

    Metadata = T.type_alias { T.any(T::Hash[Symbol, Object], T::Array[Object]) }
    Example  = T.type_alias { T.proc.params(arg0: T.nilable(Metadata)).void    }

    sig { params(name: String, example: Example).void }
    def shared_examples(name, &example)
      raise(ArgumentError, "Shared context/example #{name.inspect} already exists") if examples.key?(name)

      examples[name] = example
    end
    alias shared_context shared_examples

    sig { params(name: String, metadata: Metadata).void }
    def include_examples(name, metadata = {})
      example =
        examples.fetch(name) do
          raise(ArgumentError, "Unknown shared context/example named #{name.inspect}")
        end

      class_exec(metadata, &example)
    end
    alias include_context include_examples

  private

    sig { returns(T::Hash[String, Example]) }
    def examples
      @examples ||= T.let({}, T.nilable(T::Hash[String, Example]))
    end

    sig { params(descendant: T.class_of(Minitest::Spec)).void }
    def inherited(descendant)
      add_examples(descendant)
      super
    end

    sig { params(descendant: T.class_of(Minitest::Spec)).void }
    def included(descendant)
      add_examples(descendant)
      super
    end

    sig { params(descendant: T.class_of(Minitest::Spec)).void }
    def add_examples(descendant)
      examples = T.let(descendant.instance_variable_get(:@examples), T.nilable(T::Hash[String, Example]))
      descendant.instance_variable_set(:@examples, (examples || {}).merge(self.examples))
    end
  end
end
