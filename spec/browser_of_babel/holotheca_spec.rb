# frozen_string_literal: true

RSpec.describe BrowserOfBabel::Holotheca, :aggregate_failures do
  let(:primary) do
    secondary_class = secondary
    tertiary_class = tertiary
    Class.new(described_class) do
      holarchy secondary_class >> tertiary_class
      url_format ->(*) { "_1" }
    end
  end

  let(:secondary) do
    Class.new(described_class) do
      number_format 1..100
      url_format -> { _1.to_f.fdiv(100).to_s }
    end
  end

  let(:tertiary) do
    Class.new(described_class) do
      number_format Set["rb", "txt", "md"]
      url_format -> { ".#{_1}" }
    end
  end

  describe ".holarchy" do
    it "establishes a root-level holotheca" do
      expect(primary.parent_class).to be nil
      # A mistake can cause `tertiary` to become the child class.
      expect(primary.child_class).to be secondary
    end

    it "makes #initialize simpler" do
      expect(primary.instance_method(:initialize).parameters).to eq [%i[opt number]]
    end
  end

  describe ".>>" do
    it "establishes relationships between classes" do
      expect { secondary >> primary >> tertiary }.not_to raise_error
      expect(secondary.child_class).to eq primary
      expect(primary.child_class).to eq tertiary
    end

    it "only works on subclasses of Holotheca" do
      expect { primary >> Object }.to raise_error ArgumentError
      expect { described_class >> primary }.to raise_error ArgumentError
      expect { primary >> described_class }.to raise_error ArgumentError
    end

    it "allows to mention root itself" do
      expect { primary.holarchy primary >> secondary >> tertiary }.not_to raise_error
      expect(primary.parent_class).to be nil
    end
  end

  describe ".parent_class" do
    it "returns the higher-level class in the holarchy" do
      expect(primary.parent_class).to be nil
      expect(secondary.parent_class).to be primary
      expect(tertiary.parent_class).to be secondary
    end
  end

  describe ".child_class" do
    it "returns the lower-level class in the holarchy" do
      expect(primary.child_class).to be secondary
      expect(secondary.child_class).to be tertiary
      expect(tertiary.child_class).to be nil
    end
  end

  describe ".depth" do
    it "returns distance from the primary class" do
      expect(primary.depth).to eq 0
      expect(secondary.depth).to eq 1
      expect(tertiary.depth).to eq 2
    end
  end

  describe ".number_format" do
    context "when called without an argument" do
      it "returns configured format checker" do
        expect(primary.number_format).to be nil
        expect(secondary.number_format).to eq 1..100
        expect(tertiary.number_format).to eq Set["rb", "txt", "md"]
      end
    end

    context "when when called with an argument" do
      context "when argument responds to #===" do
        let(:format) { Set[1] }

        it "sets number checker successfully" do
          expect { primary.number_format Set[1] }.not_to raise_error
          expect(primary.number_format).to eq Set[1]
        end
      end

      context "when argument does not respond to #===" do
        let(:format) { Object.new }

        # #=== is defined on Object, so (almost) any object will have it.
        # #respond_to? is also defined on Object.
        before { format.singleton_class.class_eval { undef === } }

        it "raises ArgumentError" do
          expect { primary.number_format format }.to raise_error ArgumentError
        end
      end
    end
  end

  describe ".url_format" do
    context "when called without an argument" do
      it "returns configured URI formatter" do
        expect(primary.url_format).to respond_to :call
        expect(secondary.url_format).to respond_to :call
        expect(tertiary.url_format).to respond_to :call
      end
    end

    context "when when called with an argument" do
      context "when argument responds to #call" do
        let(:format) { Object.new }

        before { format.singleton_class.class_eval { def call(num) = num * 2 } }

        it "sets URI formatter successfully" do
          expect { primary.url_format format }.not_to raise_error
          expect(primary.url_format.call("que")).to eq "queque"
        end
      end

      context "when argument does not respond to #call" do
        let(:format) { Object.new }

        it "raises ArgumentError" do
          expect { primary.url_format format }.to raise_error ArgumentError
        end
      end
    end
  end

  describe "#initialize" do
    subject(:holotheca) { secondary.new(parent, number) }

    let(:parent) { primary.new }
    let(:number) { rand(1..100) }

    context "with valid arguments" do
      it "returns a new instance" do
        expect(holotheca).to be_a secondary
      end
    end

    context "with wrong parent" do
      subject(:holotheca) { tertiary.new(parent, number) }

      it "raises InvalidHolothecaError" do
        expect { holotheca }.to raise_error BrowserOfBabel::InvalidHolothecaError
      end
    end

    context "with invalid number" do
      let(:number) { 0 }

      it "raises InvalidNumberError" do
        expect { holotheca }.to raise_error BrowserOfBabel::InvalidNumberError
      end
    end

    context "when root class has no number format" do
      it "requires no arguments for the root" do
        expect(primary.new).to be_a primary
        expect { primary.new(33) }.to raise_error BrowserOfBabel::InvalidNumberError
      end
    end

    context "when root class sets number_format" do
      before { primary.number_format 1..100 }

      it "requires `number` for the root, but no parent" do
        expect { primary.new }.to raise_error BrowserOfBabel::InvalidNumberError
        expect(primary.new(33)).to be_a primary
      end
    end
  end

  describe "#parent" do
    subject(:parent) { holotheca.parent }

    let(:holotheca) { secondary.new(root, rand(1..100)) }
    let(:root) { primary.new }

    it "returns the parent" do
      expect(parent).to be root
    end
  end

  describe "#number" do
    subject(:number) { holotheca.number }

    let(:holotheca) { secondary.new(primary.new, num) }
    let(:num) { rand(1..100) }

    it "returns the number as a String" do
      expect(number).to eq num.to_s
    end
  end

  describe "#depth" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, 50) }
    let(:tertius) { tertiary.new(secundus, "txt") }

    it "returns the same depth as .depth" do
      expect(primus.depth).to eq 0
      expect(secundus.depth).to eq 1
      expect(tertius.depth).to eq 2
    end
  end

  describe "#up" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, 50) }
    let(:tertius) { tertiary.new(secundus, "txt") }

    context "without argument" do
      it "goes up a level, except for the root which returns itself" do
        expect(primus.up).to be primus
        expect(secundus.up).to be primus
        expect(tertius.up).to be secundus
      end
    end

    context "with an argument" do
      it "goes up the specified number of levels, stopping at root" do
        expect(primus.up(33)).to be primus
        expect(secundus.up(33)).to be primus
        expect(tertius.up(33)).to be primus

        expect(tertius.up(1)).to be secundus
        expect(tertius.up(2)).to be primus
      end
    end

    context "when argument is 0" do
      it "returns itself" do
        expect(primus.up(0)).to be primus
        expect(secundus.up(0)).to be secundus
        expect(tertius.up(0)).to be tertius
      end
    end

    context "with a negative argument" do
      it "raises ArgumentError" do
        expect { secundus.up(-1) }.to raise_error ArgumentError
      end
    end

    context "with an invalid argument" do
      it "raises ArgumentError" do
        expect { secundus.up(0.5) }.to raise_error ArgumentError
      end
    end
  end

  describe "#down" do
    subject(:downer) { primus.down(number) }

    let(:primus) { primary.new }
    let(:number) { rand(5..50) }

    context "with a valid number for the level" do
      it "creates a new child holotheca with specified number" do
        expect(downer).to be_a secondary
        expect(downer.parent).to be primus
        expect(downer.number).to eq number.to_s
      end
    end

    context "with an invalid number for the level" do
      let(:number) { "rb" }

      it "raises InvalidNumberError" do
        expect { downer }.to raise_error BrowserOfBabel::InvalidNumberError
      end
    end

    context "when there is no child class for the level" do
      subject(:downer) { tertiary.new(secondary.new(primus, 1), "rb").down(nil) }

      it "raises InvalidHolothecaError" do
        expect { downer }.to raise_error BrowserOfBabel::InvalidHolothecaError
      end
    end
  end

  describe "#dig" do
    subject(:digged) { primus.dig(number, extension) }

    let(:primus) { primary.new }
    let(:number) { rand(7..77) }
    let(:extension) { %w[rb txt md].sample }

    context "with a valid list of numbers" do
      it "creates a line of holothecas" do
        expect(digged).to be_a tertiary
        expect(digged.number).to eq extension
        expect(digged.parent.number).to eq number.to_s
        expect(digged.parent.parent).to be primus
      end
    end

    context "when list of numbers is empty" do
      subject(:digged) { primus.dig }

      it "returns itself" do
        expect(digged).to be primus
      end
    end

    context "when list of numbers is invalid" do
      subject(:digged) { primus.dig(extension, number) }

      it "raises InvalidNumberError" do
        expect { digged }.to raise_error BrowserOfBabel::InvalidNumberError
      end
    end

    context "when list of numbers is too long" do
      subject(:digged) { primus.dig(number, extension, number) }

      it "raises InvalidHolothecaError" do
        expect { digged }.to raise_error BrowserOfBabel::InvalidHolothecaError
      end
    end
  end

  describe "#path" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, 50) }
    let(:tertius) { tertiary.new(secundus, "txt") }

    it "returns parents and holotheca itself" do
      expect(primus.path).to eq [primus]
      expect(secundus.path).to eq [primus, secundus]
      expect(tertius.path).to eq [primus, secundus, tertius]
    end
  end

  describe "#to_url_part" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, rand(1..9)) }
    let(:tertius) { tertiary.new(secundus, %w[txt rb].sample) }

    it "formats the number with .url_format" do
      expect(primus.to_url_part).to eq "_1"
      expect(secundus.to_url_part).to eq "0.0#{secundus.number}"
      expect(tertius.to_url_part).to eq ".#{tertius.number}"
    end
  end

  describe "#to_url" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, rand(1..9)) }
    let(:tertius) { tertiary.new(secundus, %w[txt rb].sample) }

    it "formats the whole path with .url_format and joins results" do
      expect(primus.to_url).to eq "_1"
      expect(secundus.to_url).to eq "_10.0#{secundus.number}"
      expect(tertius.to_url).to eq "_10.0#{secundus.number}.#{tertius.number}"
    end
  end
end
