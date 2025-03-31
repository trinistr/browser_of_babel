# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Page, :aggregate_failures do
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
    let(:babel) { BrowserOfBabel }
    let(:hex) { SecureRandom.hex }
    let(:wall) { rand(1..4) }
    let(:shelf) { rand(1..5) }
    let(:volume) { rand(1..32) }
    let(:page) do
      h_hex = babel::Hex.new(babel::Library.new, hex)
      h_wall = babel::Wall.new(h_hex, wall)
      h_shelf = babel::Shelf.new(h_wall, shelf)
      h_volume = babel::Volume.new(h_shelf, volume)
      described_class.new(h_volume, rand(1..410))
    end

    it "generates properly formatted URL" do
      expect(uri).to eq(
        "#{library}?#{hex}-w#{wall}-s#{shelf}-v#{format("%02d", volume)}:#{page.number}"
      )
    end
  end
end
