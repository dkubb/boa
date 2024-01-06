# typed: strong
# frozen_string_literal: true

require 'sorbet-runtime'

require_relative 'boa/instance_methods'
require_relative 'boa/class_methods'
require_relative 'boa/result'
require_relative 'boa/util'

require_relative 'boa/invalid_object'
require_relative 'boa/type'
require_relative 'boa/type/object'
require_relative 'boa/type/boolean'
require_relative 'boa/type/integer'
require_relative 'boa/type/string'
require_relative 'boa/version'

# The Boa base module
module Boa
  extend T::Helpers
  extend T::Sig
  include InstanceMethods

  mixes_in_class_methods(ClassMethods)

  requires_ancestor { T::InexactStruct }

  abstract!

  sig { params(descendant: T::Class[Boa]).void }
  def self.included(descendant)
    descendant.const_set(:Invalid, Class.new(InvalidObject))

    super
  end
end
