# frozen_string_literal: true

require_relative "container"

module InterpreterOfBabel
  # Top-level container, representing the whole Library of Babel.
  class Library < Container
    require_relative "hex"

    child_class Hex
    url_format ->(*) { "https://libraryofbabel.info/book.cgi?" }

    def initialize
      super(nil, nil)
    end
  end
end
