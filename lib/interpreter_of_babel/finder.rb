# frozen_string_literal: true

require_relative "library"

module InterpreterOfBabel
  # Finds correct page from a text reference.
  class Finder
    LEVEL_OF_PAGE = 5

    # Construct a reference to a page (or a higher level) from a string.
    # @example
    #   Finder.new.call("2ab.2.4.16.121")
    #   # => hex 2ab, wall 2, shelf 4, volume 16, page 121
    # @param reference [String]
    # @param separator [String]
    # @return [Container]
    def call(reference, separator = ".")
      numbers = reference.split(separator)
      raise ArgumentError, "reference contains too many numbers" if numbers.size > LEVEL_OF_PAGE

      Library.new.dig(*numbers)
    rescue InvalidNumberError
      raise ArgumentError, "not a proper reference"
    end
  end
end
