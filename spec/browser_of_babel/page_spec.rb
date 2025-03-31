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
end
