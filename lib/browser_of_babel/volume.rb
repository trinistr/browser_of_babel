# frozen_string_literal: true

require_relative "holotheca"

module BrowserOfBabel
  # Fourth-level holotheca in the library.
  # Number is between 1 and 32.
  # Contains 410 pages.
  class Volume < Holotheca
    require_relative "shelf"
    require_relative "page"

    parent_class Shelf
    child_class Page
    number_format(1..32)
    url_format ->(volume) { "-v#{format("%02d", volume)}" }
  end
end
