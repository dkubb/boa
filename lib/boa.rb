# typed: strong
# frozen_string_literal: true

require 'sorbet-runtime'

require_relative 'boa/util'
require_relative 'boa/equality'
require_relative 'boa/model_methods'
require_relative 'boa/type'
require_relative 'boa/type/object'
require_relative 'boa/type/boolean'
require_relative 'boa/type/integer'
require_relative 'boa/type/string'
require_relative 'boa/version'

# The Boa base module
module Boa
  extend T::Sig
  extend T::Helpers
  include Equality

  mixes_in_class_methods(ModelMethods)

  abstract!
end
