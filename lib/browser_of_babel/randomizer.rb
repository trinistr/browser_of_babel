# frozen_string_literal: true

require_relative "locator"

module BrowserOfBabel
  # Gets you to random places in Library of Babel.
  class Randomizer
    MAX_HEX = ("z" * 3260).to_i(36)

    def initialize(random: ::Random.new)
      @random = random
      @locator = Locator.new
    end

    # Get a random hex indetifier.
    # @return [String]
    def hex_identifier
      @random.rand(MAX_HEX).to_s(36)
    end

    # Get a random hex.
    # @return [Hex]
    def hex
      @locator.from_identifiers(hex_identifier) # : Hex
    end

    # Get a random wall identifier.
    # @return [Integer]
    def wall_identifier
      @random.rand(1..4)
    end

    # Get a random wall in a random hex.
    # @return [Wall]
    def wall
      @locator.from_identifiers(hex_identifier, wall_identifier) # : Wall
    end

    # Get a random shelf identifier.
    # @return [Integer]
    def shelf_identifier
      @random.rand(1..5)
    end

    # Get a random shelf on a random wall in a random hex.
    # @return [Shelf]
    def shelf
      @locator.from_identifiers(
        hex_identifier, wall_identifier, shelf_identifier
      ) # : Shelf
    end

    # Get a random volume identifier.
    # @return [Integer]
    def volume_identifier
      @random.rand(1..32)
    end

    # Get a random volume on a random shelf and so on.
    # @return [Volume]
    def volume
      @locator.from_identifiers(
        hex_identifier, wall_identifier, shelf_identifier, volume_identifier
      ) # : Volume
    end

    # Get a random page identifier.
    # @return [Integer]
    def page_identifier
      @random.rand(1..410)
    end

    # Get a random page in a random volume and so on.
    # @return [Page]
    def page
      @locator.from_identifiers(
        hex_identifier, wall_identifier, shelf_identifier, volume_identifier, page_identifier
      ) # : Page
    end
  end
end
