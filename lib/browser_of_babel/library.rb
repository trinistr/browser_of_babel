# frozen_string_literal: true

require_relative "holotheca"
require_relative "hex"
require_relative "wall"
require_relative "shelf"
require_relative "volume"
require_relative "page"

module BrowserOfBabel
  # Top-level holotheca, representing the whole Library of Babel.
  class Library < Holotheca
    self >> Hex >> Wall >> Shelf >> Volume >> Page

    url_format ->(*) { "https://libraryofbabel.info/book.cgi?" }

    def initialize
      super(nil, nil)
    end
  end
end
