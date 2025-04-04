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

    # Find a holotheca from a reference, possibly extracting text from a page.
    # @example
    #   Locator.new.call("2ab.2.4.16.121")
    #   # => Library, Hex 2ab, Wall 2, Shelf 4, Volume 16, Page 121
    # @example
    #   Locator.new.call("xeh1.2.3.4.5.[1-20]")
    #   # => blyxpmaggmbnbri ,xso
    # @param reference [String]
    # @return [Holotheca]
    # @raise [ArgumentError] if +reference+ does not match +format+
    # @raise [InvalidIdentifierError] if +reference+ contains invalid identifiers
    def call(reference)
      match = format.match(reference)
      raise ArgumentError, "reference is invalid" unless match

      identifiers =
        match[:separator] ? match[:holotheca].split(match[:separator]) : match[:holotheca]
      holotheca = Library.new.dig(*identifiers)
      return holotheca unless match[:range]

      extract_text(holotheca, match[:range])
    end

    private

    def extract_text(page, text_range)
      ranges = text_range.split(",").map { _1.include?("-") ? to_range(_1) : _1.to_i }
      ranges.map { page[_1] }.join
    end

    def to_range(expression)
      expression.split("-").map(&:to_i).then { _1.._2 }
    end
  end
end
