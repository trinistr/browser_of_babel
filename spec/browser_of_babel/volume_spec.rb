# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Volume, :aggregate_failures do
  it "is a child of Shelf" do
    expect(described_class.parent_class).to be BrowserOfBabel::Shelf
  end

  it "is a parent of Page" do
    expect(described_class.child_class).to be BrowserOfBabel::Page
  end

  it "has a depth of 4" do
    expect(described_class.depth).to be 4
  end
end
