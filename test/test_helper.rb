# typed: strong
# frozen_string_literal: true

require 'simplecov'

require 'minitest/autorun'
require 'mutant/minitest/coverage'
require 'sorbet-runtime'

require_relative 'support/type_behaviour'

require 'boa'

class Person
  include Boa

  prop :name, String

  finalize
end
