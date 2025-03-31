# frozen_string_literal: true

require "net/http"
require "nokogiri"

module BrowserOfBabel
  # Proxy class to get page's content from the actual library.
  class PageContent
    # @param page [Page]
    def initialize(page)
      @page = page
    end

    # Get the page's title (it's book title + number of the page).
    # @return [String]
    def title
      html.title
    end

    # Get the page's contents as a blob of text.
    # @return [String]
    def text
      @text ||= html.css("pre#textblock").text.delete("\n")
    end

    private

    def html
      @html ||= Nokogiri.HTML(Net::HTTP.get(URI(@page.to_url)))
    end
  end
end
