# typed: strong
# frozen_string_literal: true

require 'simplecov' unless defined?(Mutant)

require 'minitest/autorun'
require 'mutant/minitest/coverage'
require 'prop_check'
require 'sorbet-runtime'

require_relative 'support/instance_methods_behaviour'
require_relative 'support/mutant_coverage'
require_relative 'support/strict_matchers'
require_relative 'support/type_behaviour'
require_relative 'support/property_generators'

require 'boa'

ROOT_PATH = T.let(Pathname.new(__dir__).parent, Pathname)

Minitest::Test.extend(MutantCoverage)
Minitest::Assertions.prepend(StrictMatchers)

G = PropCheck::Generators
