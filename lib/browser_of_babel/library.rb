# frozen_string_literal: true

require_relative "holotheca"

module BrowserOfBabel
  # Top-level holotheca, representing the whole Library of Babel.
  class Library < Holotheca
    require_relative "hex"

    child_class Hex
    url_format ->(*) { "https://libraryofbabel.info/book.cgi?" }

    def initialize
      super(nil, nil)
    end
  end
end
