# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Shelf, :aggregate_failures do
  it "is a child of Wall" do
    expect(described_class.parent_class).to be BrowserOfBabel::Wall
  end

  it "is a parent of Volume" do
    expect(described_class.child_class).to be BrowserOfBabel::Volume
  end

  it "has a depth of 3" do
    expect(described_class.depth).to be 3
  end
end
