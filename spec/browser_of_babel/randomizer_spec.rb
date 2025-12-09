# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Randomizer do
  let(:randomizer) { described_class.new }

  describe "#initialize" do
    it "can be initialized with a random Random" do
      expect(randomizer.hex_identifier).not_to eq described_class.new.hex_identifier
    end

    it "can be initialized with a specific Random" do
      seed = Random.new_seed
      randomizer_1 = described_class.new(random: Random.new(seed))
      randomizer_2 = described_class.new(random: Random.new(seed))
      expect(randomizer_1.hex_identifier).to eq randomizer_2.hex_identifier
    end
  end

  describe "#hex_identifier" do
    it "produces a random valid identifier" do
      expect(randomizer.hex_identifier).to match BrowserOfBabel::Hex.identifier_format
      expect(randomizer.hex_identifier).not_to eq randomizer.hex_identifier
    end
  end

  describe "#wall_identifier" do
    it "produces a random valid identifier" do
      expect(randomizer.wall_identifier).to match BrowserOfBabel::Wall.identifier_format
    end
  end

  describe "#shelf_identifier" do
    it "produces a random valid identifier" do
      expect(randomizer.shelf_identifier).to match BrowserOfBabel::Shelf.identifier_format
    end
  end

  describe "#volume_identifier" do
    it "produces a random valid identifier" do
      expect(randomizer.volume_identifier).to match BrowserOfBabel::Volume.identifier_format
    end
  end

  describe "#page_identifier" do
    it "produces a random valid identifier" do
      expect(randomizer.page_identifier).to match BrowserOfBabel::Page.identifier_format
    end
  end

  describe "#hex" do
    it "produces a random holotheca" do
      expect(randomizer.hex).to be_a BrowserOfBabel::Hex
      expect(randomizer.hex.identifier).not_to eq randomizer.hex.identifier
    end
  end

  describe "#wall" do
    it "produces a random holotheca" do
      expect(randomizer.wall).to be_a BrowserOfBabel::Wall
    end
  end

  describe "#shelf" do
    it "produces a random holotheca" do
      expect(randomizer.shelf).to be_a BrowserOfBabel::Shelf
    end
  end

  describe "#volume" do
    it "produces a random holotheca" do
      expect(randomizer.volume).to be_a BrowserOfBabel::Volume
    end
  end

  describe "#page" do
    it "produces a random holotheca" do
      expect(randomizer.page).to be_a BrowserOfBabel::Page
    end
  end
end
