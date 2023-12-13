# typed: strong
# frozen_string_literal: true

require 'simplecov' unless defined?(Mutant)

require 'minitest/autorun'
require 'mutant/minitest/coverage'
require 'sorbet-runtime'

require_relative 'support/shared_setup'
require_relative 'support/type_behaviour'

require 'boa'

Minitest::Spec.extend(Support::SharedSetup)
