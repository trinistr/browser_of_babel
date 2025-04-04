# frozen_string_literal: true

require_relative "holotheca"
require_relative "page_content"

module BrowserOfBabel
  # Bottom-level holotheca in the library.
  # Identifier is between 1 and 410.
  # Contains 3200 characters:
  #   - lowercase latin letters,
  #   - digits,
  #   - spaces,
  #   - commas and periods.
  class Page < Holotheca
    identifier_format(1..410)
    url_format ->(page) { ":#{page}" }

    # Get the book's title.
    # @return [String]
    def book_title
      title[/.+(?= \d+\z)/]
    end

    # Get the page's title (it's book title + number of the page).
    # @return [String]
    def title
      content.title
    end

    # Get the page's contents as a blob of text.
    # @return [String]
    def text
      content.text
    end

    # Get text from the page.
    # @overload page[start, length]
    #   @param start [Integer]
    #   @param length [Integer]
    # @overload page[range]
    #   @param range [Range<Integer>]
    # @overload page[start]
    #   @param start [Integer]
    # @see String#[]
    def [](start_or_range, length = nil)
      range =
        if length
          (start_or_range - 1)..(start_or_range + length - 1)
        elsif start_or_range.is_a?(Range)
          (start_or_range.begin - 1)..(start_or_range.end - 1)
        else
          (start_or_range - 1)..(start_or_range - 1)
        end
      text.[](range)
    end

    private

    def content
      @content ||= PageContent.new(self)
    end
  end
end
