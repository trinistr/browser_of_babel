# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Page, :aggregate_failures do
  include_context "with mocked page request"

  let(:page) { BrowserOfBabel::Library.new.dig("1", 2, 3, 4, 5) }

  it "is a child of Volume" do
    expect(described_class.parent_class).to be BrowserOfBabel::Volume
  end

  it "is a parent of nothing" do
    expect(described_class.child_class).to be nil
  end

  it "has a depth of 5" do
    expect(described_class.depth).to be 5
  end

  describe "#to_url" do
    subject(:uri) { page.to_url }

    let(:library) { "https://libraryofbabel.info/book.cgi" }
    let(:hex) { SecureRandom.hex }
    let(:wall) { rand(1..4) }
    let(:shelf) { rand(1..5) }
    let(:volume) { rand(1..32) }
    let(:page) { BrowserOfBabel::Library.new.dig(hex, wall, shelf, volume, rand(1..410)) }

    it "generates properly formatted URL" do
      expect(uri).to eq(
        "#{library}?#{hex}-w#{wall}-s#{shelf}-v#{format("%02d", volume)}:#{page.identifier}"
      )
    end
  end

  describe "#title" do
    it "returns the page's <title>" do
      expect(page.title).to eq "jbcde 1"
    end
  end

  describe "#volume_title" do
    it "returns the page's <title>, stripping out the page number" do
      expect(page.volume_title).to eq "jbcde"
    end
  end

  describe "#text" do
    it "returns the full text of the page, discarding new lines" do
      expect(page.text).to eq(
        "abcdefghijklmnopqrstuvwxyz123409876543211234567890,. 1234567890,. 12340987654321"
      )
    end
  end

  describe "#[]" do
    context "when given start and length" do
      it "returns a range of characters from the page" do
        expect(page[5, 23]).to eq "efghijklmnopqrstuvwxyz12"
      end
    end

    context "when given a range" do
      it "returns a range of characters from the page" do
        expect(page[5..28]).to eq "efghijklmnopqrstuvwxyz12"
      end
    end

    context "when given a single index" do
      it "returns a single character from the page" do
        expect(page[41]).to eq "1"
      end
    end
  end
end
