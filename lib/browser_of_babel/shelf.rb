# frozen_string_literal: true

require_relative "holotheca"

module BrowserOfBabel
  # Third-level holotheca in the library.
  # Number is between 1 and 5.
  # Contains 32 volumes.
  class Shelf < Holotheca
    require_relative "wall"
    require_relative "volume"

    parent_class Wall
    child_class Volume
    number_format(1..5)
    url_format ->(shelf) { "-s#{shelf}" }
  end
end
