# frozen_string_literal: true

require_relative "container"
require_relative "page_content"

module InterpreterOfBabel
  # Bottom-level container in the library.
  # Number is between 1 and 410.
  # Contains 3200 characters:
  #   - lowercase latin letters,
  #   - digits,
  #   - spaces,
  #   - commas and periods.
  class Page < Container
    require_relative "volume"

    parent_class Volume
    number_format(1..410)
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
    # @overload page[start..end]
    #   @param start [Integer]
    #   @param end [Integer]
    # @see String#[]
    def [](start_or_range, length = nil)
      range =
        if length
          (start_or_range - 1)..(start_or_range + length - 1)
        else
          (start_or_range.begin - 1)..(start_or_range.end - 1)
        end
      text.[](range)
    end

    private

    def content
      @content ||= PageContent.new(self)
    end
  end
end
