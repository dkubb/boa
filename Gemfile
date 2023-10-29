# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

gemspec

group :development, :test do
  gem 'bundler-audit', '~> 0.9.1'   # Audit dependencies in Gemfile for vulnerabilities
  gem 'rubocop',       '~> 1.57.2'  # Linter for enforcing Ruby coding style
end
