# frozen_string_literal: true

require_relative "holotheca"

module BrowserOfBabel
  # Second-level holotheca in the library.
  # Identifier is between 1 and 4.
  # Contains 5 shelves.
  class Wall < Holotheca
    identifier_format(1..4)
    url_format ->(wall) { "-w#{wall}" }
  end
end
