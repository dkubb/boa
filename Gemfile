# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

gemspec

group :development, :test do
  gem 'bundler-audit',       '~> 0.9.1'                   # Audit dependencies in Gemfile for vulnerabilities
  gem 'minitest',            '~> 5.20.0'                  # Ruby testing framework
  gem 'mutant',              '~> 0.11.26'                 # Mutation testing for Ruby
  gem 'mutant-minitest',     '~> 0.11.26'                 # Minitest integration for Mutant
  gem 'rake',                '~> 13.1.0'                  # Scripting utility similar to Make
  gem 'rubocop',             '~> 1.58.0'                  # Linter for enforcing Ruby coding style
  gem 'rubocop-minitest',    '~> 0.33.0'                  # RuboCop extension specific to Minitest
  gem 'rubocop-performance', '~> 1.19.1'                  # RuboCop extension for enforcing performance best practices
  gem 'rubocop-rake',        '~> 0.6.0'                   # RuboCop rules for Rake tasks
  gem 'rubocop-sorbet',      '~> 0.7.6', require: false   # Add Sorbet support to RuboCop
  gem 'rubocop-yard',        '~> 0.8.2'                   # RuboCop extension for YARD
  gem 'simplecov',           '~> 0.22.0'                  # Code coverage analysis for Ruby
  gem 'sorbet',              '~> 0.5.11144'               # Type checker for Ruby
  gem 'tapioca',             '~> 0.11.12', require: false # Generate RBI files for gems and standard library
  gem 'unparser',            '~> 0.6.10', require: false  # Library for unparsing Ruby expressions
  gem 'yard-doctest',        '~> 0.1.17'                  # Run doctests via YARD
  gem 'yard-sorbet',         '~> 0.8.1'                   # Add Sorbet support to YARD
  gem 'yardstick',           '~> 0.9.9'                   # Measure YARD documentation coverage

  source 'https://oss:sxCL1o1navkPi2XnGB5WYBrhpY9iKIPL@gem.mutant.dev' do
    gem 'mutant-license', '~> 0.1.1' # Mutant license
  end
end
