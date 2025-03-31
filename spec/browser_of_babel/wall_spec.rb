# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Wall, :aggregate_failures do
  it "is a child of Hex" do
    expect(described_class.parent_class).to be BrowserOfBabel::Hex
  end

  it "is a parent of Shelf" do
    expect(described_class.child_class).to be BrowserOfBabel::Shelf
  end

  it "has a depth of 2" do
    expect(described_class.depth).to be 2
  end
end
