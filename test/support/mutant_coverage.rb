# typed: strong
# frozen_string_literal: true

module MutantCoverage
  extend T::Sig

  # Define interface for #cover
  sig { params(pattern: String).void }
  def cover(pattern) end

  # Add #cover implementation
  sig { params(descendant: T.class_of(Minitest::Test)).void }
  def self.extended(descendant)
    descendant.singleton_class.prepend(Mutant::Minitest::Coverage)
  end
end
