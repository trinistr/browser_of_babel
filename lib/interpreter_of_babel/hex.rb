# frozen_string_literal: true

require_relative "container"

module InterpreterOfBabel
  # First-level container in the library.
  # Number is a combination of lowercase (latin) letters and (arabic) digits up to 3260 long.
  # Contains 4 walls.
  class Hex < Container
    require_relative "library"
    require_relative "wall"

    parent_class Library
    child_class Wall
    number_format(/\A[a-z0-9]{1,3260}\z/)
    url_format(&:to_s)
  end
end
