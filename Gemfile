# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

gemspec

group :development, :test do
  gem 'bundler-audit',       '~> 0.9.1'                   # Audit dependencies in Gemfile for vulnerabilities
  gem 'rubocop',             '~> 1.57.2'                  # Linter for enforcing Ruby coding style
  gem 'rubocop-performance', '~> 1.19.1'                  # RuboCop extension for enforcing performance best practices
  gem 'rubocop-sorbet',      '~> 0.7.4', require: false   # Add Sorbet support to RuboCop
  gem 'sorbet',              '~> 0.5.11066'               # Type checker for Ruby
  gem 'tapioca',             '~> 0.11.9', require: false  # Generate RBI files for gems and standard library
  gem 'unparser',            '~> 0.6.9', require: false   # Library for unparsing Ruby expressions
end
