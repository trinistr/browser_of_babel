# frozen_string_literal: true

require_relative "browser_of_babel/version"
require_relative "browser_of_babel/library"
require_relative "browser_of_babel/locator"

# Browser for Library of Babel.
# @see https://libraryofbabel.info
module BrowserOfBabel
  # Base error class for BrowserOfBabel.
  class Error < StandardError; end

  # Holotheca does not support this identifier.
  class InvalidIdentifierError < Error; end
  # Trying to go between library holotheca levels incorrectly, e.g. from hex to shelf.
  class InvalidHolothecaError < Error; end
end
