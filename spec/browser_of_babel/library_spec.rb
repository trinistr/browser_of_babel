# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Library, :aggregate_failures do
  it "does not have a parent" do
    expect(described_class.parent_class).to be nil
  end

  it "is a parent of Hex" do
    expect(described_class.child_class).to be BrowserOfBabel::Hex
  end

  it "has a depth of 0" do
    expect(described_class.depth).to be 0
  end

  describe "#to_s_part" do
    it "returns 'Library of Babel'" do
      expect(described_class.new.to_s_part).to eq "Library of Babel"
    end
  end
end
