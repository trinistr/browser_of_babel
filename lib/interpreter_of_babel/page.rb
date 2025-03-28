# frozen_string_literal: true

require "net/http"
require "nokogiri"
require_relative "container"

module InterpreterOfBabel
  # Bottom-level container in the library.
  # Number is between 1 and 410.
  # Contains 3200 characters.
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
      html.title
    end

    # Get the page's contents as a blob of text.
    # @return [String]
    def content
      @content ||= html.css("pre#textblock").text.delete("\n")
    end

    # Get text from the page.
    # @overload page[start, length]
    #   @param start [Integer]
    #   @param length [Integer]
    # @overload page[start..end]
    #   @param start [Integer]
    #   @param end [Integer]
    # @see String#[]
    def [](...)
      content.[](...)
    end

    private

    def html
      @html ||= Nokogiri.HTML(Net::HTTP.get(URI(to_url)))
    end
  end
end
