# frozen_string_literal: true

SimpleCov.start do
  enable_coverage :branch
  primary_coverage :branch

  minimum_coverage line: 100, branch: 100
  refuse_coverage_drop :line, :branch

  add_filter %r{\A/test/}
end
