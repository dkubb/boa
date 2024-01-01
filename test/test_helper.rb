# typed: strong
# frozen_string_literal: true

require 'simplecov' unless defined?(Mutant)

require 'minitest/autorun'
require 'mutant/minitest/coverage'
require 'sorbet-runtime'

require_relative 'support/instance_methods_behaviour'
require_relative 'support/mutant_coverage'
require_relative 'support/type_behaviour'

require 'boa'

Minitest::Test.extend(MutantCoverage)
