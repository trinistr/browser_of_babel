# frozen_string_literal: true

require_relative "container"

module InterpreterOfBabel
  # Third-level container in the library.
  # Number is between 1 and 5.
  # Contains 32 volumes.
  class Shelf < Container
    require_relative "wall"
    require_relative "volume"

    parent_class Wall
    child_class Volume
    number_format(1..5)
    url_format ->(shelf) { "-s#{shelf}" }
  end
end
