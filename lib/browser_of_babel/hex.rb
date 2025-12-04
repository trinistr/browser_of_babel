# frozen_string_literal: true

require_relative "holotheca"

module BrowserOfBabel
  # First-level holotheca in the library.
  # Identifier is a combination of lowercase (latin) letters and (arabic) digits up to 3260 long.
  # Contains 4 walls.
  class Hex < Holotheca
    FORMAT = "[a-z0-9]{1,3260}"

    identifier_format(/\A#{FORMAT}\z/o)
  end
end
