# frozen_string_literal: true

Dir["#{File.expand_path(__dir__)}/browser_of_babel/*"].each { require _1 }

# Browser and interpter for Library of Babel.
# @see https://libraryofbabel.info
module BrowserOfBabel
  class Error < StandardError; end

  # Holotheca does not support this number.
  class InvalidNumberError < Error; end
  # Trying to go between library holotheca levels incorrectly, e.g. from hex to shelf.
  class InvalidHolothecaError < Error; end
  # Trying to fill a holotheca class-level setting with an invalid value.
  class InvalidSettingError < Error; end
end
