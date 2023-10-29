# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = 'boa'
  spec.version     = '0.1.0'
  spec.authors     = ['Dan Kubb']
  spec.email       = %w[github@dan.kubb.ca]
  spec.summary     = 'A Ruby gem for defining immutable, strongly-typed data structures with built-in validation.'
  spec.description = 'Boa provides a concise API for defining data classes with type checking, validation, and immutability.'
  spec.homepage    = 'https://github.com/dkubb/boa'
  spec.license     = 'MIT'

  spec.files = %w[LICENSE README.md]

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '~> 3.2.2'

  spec.add_dependency('ice_nine',       '~> 0.11.2')
  spec.add_dependency('sorbet-runtime', '~> 0.5.11066')
end
