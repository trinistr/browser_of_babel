# frozen_string_literal: true

Dir["#{File.expand_path(__dir__)}/interpreter_of_babel/*"].each { require _1 }

# Browser and interpter for Library of Babel.
# @see https://libraryofbabel.info
module InterpreterOfBabel
  class Error < StandardError; end
  # Container does not support this number.
  class InvalidNumberError < Error; end
  # Trying to go between library container levels incorrectly, e.g. from hex to shelf.
  class InvalidContainerError < Error; end
  # Trying to fill a container class-level setting with an invalid value.
  class InvalidSettingError < Error; end

  LIBRARY_BASE = "https://libraryofbabel.info/book.cgi?"
end
