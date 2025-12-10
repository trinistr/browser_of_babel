# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Locator, :aggregate_failures do
  subject(:result) { locator.call(reference) }

  let(:locator) { described_class.new }

  include_context "with mocked page request"

  it "uses DEFAULT_FORMAT by default" do
    expect(locator.format).to be described_class::DEFAULT_FORMAT
  end

  context "when given a partial reference" do
    let(:reference) { "2abz0.2" }

    it "returns corresponding holotheca" do
      expect(result).to be_a BrowserOfBabel::Wall
      expect(result.to_s).to eq "Library of Babel, Hex 2abz0, Wall 2"
    end
  end

  context "when given a full page reference" do
    let(:reference) { "2abz0.2.4.5.12" }

    it "returns a Page" do
      expect(result).to be_a BrowserOfBabel::Page
      expect(result.to_s).to eq "Library of Babel, Hex 2abz0, Wall 2, Shelf 4, Volume 5, Page 12"
    end
  end

  context "when given a reference with a text range" do
    let(:reference) { "2abz0.2.4.5.12[5-28]" }

    it "extracts text from a page" do
      expect(result).to be_a String
      expect(result).to eq "efghijklmnopqrstuvwxyz12"
    end

    context "with an extra separator" do
      let(:reference) { "2abz0.2.4.5.12.[5-28]" }

      it "extracts text from a page" do
        expect(result).to be_a String
        expect(result).to eq "efghijklmnopqrstuvwxyz12"
      end
    end
  end

  context "when given a reference with a text index" do
    let(:reference) { "2abz0.2.4.5.12.41" }

    it "extracts a single character from a page" do
      expect(result).to be_a String
      # New lines are ignored, so 41 corresponds to the first character on second line.
      expect(result).to eq "1"
    end
  end

  context "when given a reference with several text ranges" do
    let(:reference) { "2abz0.2.4.5.12[5-28,30,41-45]" }

    it "extracts text from a page, combining all ranges" do
      expect(result).to be_a String
      expect(result).to eq "efghijklmnopqrstuvwxyz12412345"
    end
  end

  context "if given an invalid reference" do
    it "raises InvalidIdentifierError if reference does not match format" do
      expect { locator.call("2.abz0.2") }.to raise_error(
        BrowserOfBabel::InvalidIdentifierError, "reference is invalid"
      )
      expect { locator.call("2abz0/2") }.to raise_error(
        BrowserOfBabel::InvalidIdentifierError, "reference is invalid"
      )
    end

    it "raises InvalidIdentifierError if identifier is impossible" do
      # Wall 8 does not exist.
      expect { locator.call("2abz0.8") }.to raise_error(
        BrowserOfBabel::InvalidIdentifierError, /does not correspond to expected format/
      )
    end

    it "raises InvalidHolothecaError if text ranges are set on a non-page" do
      expect { locator.call("2abz0.2[1-5]") }.to raise_error(
        BrowserOfBabel::InvalidHolothecaError, "text can only be extracted from a page"
      )
    end
  end

  context "with a custom format" do
    let(:locator) { described_class.new(format: only_hexes) }
    let(:only_hexes) { /\A(?<holotheca>[1-9]{1,999}(?<separator>){0})(?<range>){0}\z/ }

    let(:reference) { "2123" }

    it "follows the format" do
      expect(result).to be_a BrowserOfBabel::Hex
      expect { locator.call("2123.2") }.to raise_error(
        BrowserOfBabel::InvalidIdentifierError, "reference is invalid"
      )
    end

    context "and using a custom separator" do
      let(:locator) { described_class.new(format: not_only_hexes) }
      let(:not_only_hexes) { /\A(?<holotheca>[1-9]{1,999}(?<separator>!)[1-6])(?<range>){0}\z/ }

      let(:reference) { "2123!2" }

      it "successfully parses a reference" do
        expect(result).to be_a BrowserOfBabel::Wall
      end
    end
  end
end
