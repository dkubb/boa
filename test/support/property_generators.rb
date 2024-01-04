# typed: strong
# frozen_string_literal: true

module PropertyGenerators
  module Type
    extend T::Sig

    sig { returns(PropCheck::Generator) }
    def self.instance
      subclasses = Boa::Type.subclasses.select(&:name)

      instance =
        one_of(constant_values(subclasses)).bind do |klass|
          klass = T.let(klass, T.class_of(Boa::Type))

          G.instance(klass, name, includes: includes(klass))
        end

      T.let(instance, PropCheck::Generator)
    end

    sig { params(value: Object).returns(PropCheck::Generator) }
    def self.constant(value)
      T.let(G.constant(value), PropCheck::Generator)
    end
    private_class_method(:constant)

    sig { params(values: T::Array[Object]).returns(T::Array[PropCheck::Generator]) }
    def self.constant_values(values)
      values.map { |value| constant(value) }
    end

    sig { params(choices: T::Array[PropCheck::Generator]).returns(PropCheck::Generator) }
    def self.one_of(choices)
      generator = T.let(G.choose(choices.length), PropCheck::Generator)

      selected =
        generator.bind do |index|
          choices.fetch(T.let(index, Integer))
        end

      T.let(selected, PropCheck::Generator)
    end
    private_class_method(:one_of)

    sig { params(element_generator: PropCheck::Generator, options: T.untyped).returns(PropCheck::Generator) }
    def self.array(element_generator, **options)
      T.let(G.array(element_generator, **options), PropCheck::Generator)
    end

    sig { returns(PropCheck::Generator) }
    def self.name
      alpha_char = one_of(constant_values([*'a'..'z', *'A'..'Z']))
      digit      = one_of(constant_values(Array('0'..'9')))
      underscore = constant('_')

      head = T.let(one_of([alpha_char, underscore]),                            PropCheck::Generator)
      tail = T.let(array(one_of([alpha_char, digit, underscore]), empty: true), PropCheck::Generator)

      name =
        head.bind do |prefix|
          tail.map do |suffix|
            prefix = T.let(prefix, String)
            suffix = T.let(suffix, T::Array[String])

            T.let([prefix, *suffix], T::Array[String]).join.to_sym
          end
        end

      T.let(name, PropCheck::Generator)
    end
    private_class_method(:name)

    sig { params(_klass: T.class_of(Boa::Type)).returns(PropCheck::Generator) }
    def self.includes(_klass)
      # TODO: depend on type class
      T.let(one_of([constant(nil)]), PropCheck::Generator)
    end
    private_class_method(:includes)
  end
end
