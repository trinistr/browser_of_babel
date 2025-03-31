# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Hex, :aggregate_failures do
  it "is a child of Library" do
    expect(described_class.parent_class).to be BrowserOfBabel::Library
  end

  it "is a parent of Wall" do
    expect(described_class.child_class).to be BrowserOfBabel::Wall
  end

  it "has a depth of 1" do
    expect(described_class.depth).to be 1
  end
end
