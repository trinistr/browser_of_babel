# frozen_string_literal: true

require_relative "browser_of_babel/library"
require_relative "browser_of_babel/locator"
require_relative "browser_of_babel/randomizer"
require_relative "browser_of_babel/version"

# Browser for Library of Babel.
# @see https://libraryofbabel.info
module BrowserOfBabel
  # Base error class for BrowserOfBabel.
  class Error < StandardError; end

  # A holotheca does not support an identifier.
  class InvalidIdentifierError < Error; end
  # Trying to go between library holotheca levels incorrectly, e.g. from hex to shelf;
  # or trying to extract text from a non-Page holotheca.
  class InvalidHolothecaError < Error; end
end
