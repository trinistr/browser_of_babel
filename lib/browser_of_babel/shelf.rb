# frozen_string_literal: true

require_relative "holotheca"

module BrowserOfBabel
  # Third-level holotheca in the library.
  # Identifier is between 1 and 5.
  # Contains 32 volumes.
  class Shelf < Holotheca
    identifier_format(1..5)
    url_format ->(shelf) { "-s#{shelf}" }
  end
end
