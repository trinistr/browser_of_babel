# frozen_string_literal: true

require_relative "library"

module BrowserOfBabel
  # Finds correct holotheca or text from a reference.
  class Locator
    MAX_DEPTH = Page.depth
    SEP = /\./
    HOLOTHECA_FORMAT =
      /(?<holotheca>#{Hex::FORMAT}(?:(?<separator>#{SEP})\d+){0,#{MAX_DEPTH - 1}})/o
    TEXT_RANGE_FORMAT = /(?>(?<range>\d+)|\[(?<range>(?>\d+-\d+|\d+)(?:,\s*(?>\d+-\d+|\d+))*)\])/o
    DEFAULT_FORMAT = /\A#{HOLOTHECA_FORMAT}(?:#{SEP}#{TEXT_RANGE_FORMAT})?\z/o

    # @return [Regexp]
    attr_reader :format

    # @param format [Regexp] regexp to parse references;
    #   must have capturing groups +holotheca+, +separator+, +range+ (text ranges),
    #   see {DEFAULT_FORMAT} for inspiration
    def initialize(format: DEFAULT_FORMAT)
      @format = format
    end

    # Find a holotheca from a string reference, possibly extracting text from a page.
    # @example
    #   Locator.new.call("2ab.2.4.16.121")
    #   # => Library, Hex 2ab, Wall 2, Shelf 4, Volume 16, Page 121
    # @example
    #   locator = Locator.new
    #   locator.call("xeh1.2.3.4.5.[1-20]")
    #   # => blyxpmaggmbnbri ,xso
    #   locator.call("xeh1.2.3.4.5.[1-10,12,15,18-20]")
    #   # => blyxpmaggmnixso
    # @param reference [String]
    # @return [Holotheca] if reference does not contain text ranges
    # @return [String] if reference points to a page and contains text ranges
    # @raise [ArgumentError] if +reference+ does not match expected +format+
    # @raise [InvalidIdentifierError] if +reference+ contains invalid identifiers
    # @raise [InvalidHolothecaError] if +reference+ contains text ranges,
    #   but does not point to a page
    def call(reference)
      match = format.match(reference)
      return invalid_reference unless match

      reference = match[:holotheca] # : String
      identifiers =
        match[:separator] ? reference.split(match[:separator]) : reference
      identifiers = Array(identifiers) # : Array[String]
      from_identifiers(*identifiers, ranges: extract_ranges(match[:range]))
    end

    alias from_string call

    # Find a holotheca from an array of identifiers, possibly extracting text from a page.
    # @param identifiers [Array<String, Integer>]
    # @param ranges [Array<Integer, Range<Integer>>]
    # @return [Holotheca] if +ranges+ is +nil+
    # @return [String] if +identifiers+ point to a page, and +ranges+ contain text ranges
    # @raise [ArgumentError] if +ranges+ contain an invalid range
    # @raise [InvalidIdentifierError] if +identifiers+ are invalid
    # @raise [InvalidHolothecaError] if +identifiers+ do not point to a {Page},
    #   but +ranges+ is not +nil+
    def from_identifiers(*identifiers, ranges: nil)
      holotheca = Library.new.dig(*identifiers)
      return holotheca unless ranges
      return invalid_holotheca unless holotheca.is_a?(Page)

      ranges = Array(ranges)
      ranges.map { holotheca[_1] }.join
    end

    private

    def extract_ranges(text_range)
      return unless text_range

      # @type var _ : Array[Integer | Range[Integer]]
      _ = text_range.split(",").map { _1.include?("-") ? to_range(_1) : _1.to_i }
    end

    def to_range(expression)
      (_ = expression.split("-").map(&:to_i).then { _1.._2 }) # : Range[Integer]
    end

    def invalid_reference
      raise InvalidIdentifierError, "reference is invalid", caller
    end

    def invalid_holotheca
      raise InvalidHolothecaError, "text can only be extracted from a page", caller
    end
  end
end
