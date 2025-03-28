# frozen_string_literal: true

require_relative "container"

module InterpreterOfBabel
  # Second-level container in the library.
  # Number is between 1 and 4.
  # Contains 5 shelves.
  class Wall < Container
    require_relative "hex"
    require_relative "shelf"

    parent_class Hex
    child_class Shelf
    number_format(1..4)
    url_format ->(wall) { "-w#{wall}" }
  end
end
