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
      identifier_format 1..100
      url_format -> { _1.to_f.fdiv(100).to_s }
    end
  end

  let(:tertiary) do
    Class.new(described_class) do
      identifier_format Set["rb", "txt", "md"]
      url_format -> { ".#{_1}" }
    end
  end

  let(:unnamed) do
    Class.new(described_class) do
      identifier_format ->(id) { String === id || id.nil? }
      def initialize(identifier = nil) = super(nil, identifier)
    end
  end

  before do
    stub_const("Primary", primary)
    stub_const("Secondary", secondary)
    stub_const("Tertiary", tertiary)
  end

  describe ".holarchy" do
    it "establishes a root-level holotheca" do
      expect(primary.parent_class).to be nil
      # A mistake can cause `tertiary` to become the child class.
      expect(primary.child_class).to be secondary
    end

    it "makes #initialize simpler" do
      expect(primary.instance_method(:initialize).parameters).to eq [%i[opt identifier]]
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

  describe ".root" do
    it "returns the root holotheca class" do
      expect(primary.root).to be primary
      expect(secondary.root).to be primary
      expect(tertiary.root).to be primary
    end
  end

  describe ".identifier_format" do
    context "when called without an argument" do
      it "returns configured format checker" do
        expect(primary.identifier_format).to be nil
        expect(secondary.identifier_format).to eq 1..100
        expect(tertiary.identifier_format).to eq Set["rb", "txt", "md"]
      end
    end

    context "when when called with an argument" do
      context "when argument responds to #===" do
        let(:format) { Set[1] }

        it "sets identifier validator successfully" do
          expect { primary.identifier_format Set[1] }.not_to raise_error
          expect(primary.identifier_format).to eq Set[1]
        end
      end

      context "when argument does not respond to #===" do
        let(:format) { Object.new }

        # #=== is defined on Object, so (almost) any object will have it.
        # #respond_to? is also defined on Object.
        before { format.singleton_class.class_eval { undef === } }

        it "raises ArgumentError" do
          expect { primary.identifier_format format }.to raise_error ArgumentError
        end
      end

      context "when called with nil" do
        before { primary.identifier_format Set[1] }

        it "sets identifier validator to nil" do
          expect { primary.identifier_format nil }.not_to raise_error
          expect(primary.identifier_format).to be nil
        end
      end
    end
  end

  describe ".identifier_class" do
    context "if identifier_format is nil" do
      it "returns nil" do
        expect(primary.identifier_class).to be nil
      end
    end

    context "if identifier_format is a Class" do
      before { primary.identifier_format NilClass }

      it "returns that class" do
        expect(primary.identifier_class).to eq NilClass
      end
    end

    context "if identifier_format is a Range" do
      it "returns class of the first element" do
        expect(secondary.identifier_class).to eq Integer
      end
    end

    context "if identifier_format is a Set with elements of the same class" do
      it "returns class of the first element" do
        expect(tertiary.identifier_class).to eq String
      end
    end

    context "if identifier_format is a Set with different classes" do
      before { primary.identifier_format Set[nil, false, true] }

      it "returns nil" do
        expect(primary.identifier_class).to be nil
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
    subject(:holotheca) { secondary.new(parent, identifier) }

    let(:parent) { primary.new }
    let(:identifier) { rand(1..100) }

    context "with valid arguments" do
      it "returns a new instance" do
        expect(holotheca).to be_a secondary
      end
    end

    context "with wrong parent" do
      subject(:holotheca) { tertiary.new(parent, identifier) }

      it "raises InvalidHolothecaError" do
        expect { holotheca }.to raise_error BrowserOfBabel::InvalidHolothecaError
      end
    end

    context "with invalid identifier" do
      let(:identifier) { 0 }

      it "raises InvalidIdentifierError" do
        expect { holotheca }.to raise_error BrowserOfBabel::InvalidIdentifierError
      end
    end

    context "with inconvertible identifier format" do
      let(:identifier) { false }

      before { secondary.identifier_format Set[nil, false, true] }

      it "returns a new instance with specified identifier" do
        expect(holotheca.identifier).to be false
      end
    end

    context "with identifier of a different class than expected" do
      context "if identifier_class is Integer" do
        let(:identifier) { rand(1..100).to_s }

        it "returns a new instance with identifier converted with #to_i" do
          expect(holotheca.identifier).to be_a Integer
        end
      end

      context "if identifier_class is String" do
        let(:identifier) { rand(1..100) }

        before { secondary.identifier_format(/\A\d+\z/) }

        it "returns a new instance with identifier converted with #to_s" do
          expect(holotheca.identifier).to be_a String
        end
      end

      context "if identifier_class is Symbol" do
        let(:identifier) { rand(1..100).to_s }

        before { secondary.identifier_format Symbol }

        it "returns a new instance with identifier converted with #to_sym" do
          expect(holotheca.identifier).to be_a Symbol
        end
      end

      context "if there is no known conversion" do
        let(:identifier) { 1 }

        before { secondary.identifier_format Float }

        it "raises InvalidIdentifierError" do
          expect { holotheca }
            .to raise_error BrowserOfBabel::InvalidIdentifierError, "unknown conversion to Float"
        end
      end
    end

    context "when root class has no identifier format" do
      it "requires no arguments for the root" do
        expect(primary.new).to be_a primary
        expect { primary.new(33) }
          .to raise_error BrowserOfBabel::InvalidIdentifierError,
                          "identifier 33 does not correspond to expected format for Primary"
      end
    end

    context "when root class sets identifier_format" do
      before { primary.identifier_format 1..100 }

      it "requires `identifier` for the root, but no parent" do
        expect { primary.new }
          .to raise_error BrowserOfBabel::InvalidIdentifierError,
                          "identifier nil does not correspond to expected format for Primary"
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

  describe "#identifier" do
    subject(:identifier) { holotheca.identifier }

    let(:holotheca) { secondary.new(primary.new, num) }
    let(:num) { rand(1..100) }

    it "returns the identifier" do
      expect(identifier).to eq num
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

  describe "#root" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, 50) }
    let(:tertius) { tertiary.new(secundus, "txt") }

    it "returns the root holotheca" do
      expect(primus.root).to be primus
      expect(secundus.root).to be primus
      expect(tertius.root).to be primus
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
      it "goes up the specified identifier of levels, stopping at root" do
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

    context "when argument has #to_int" do
      let(:arg) { Object.new }

      before { def arg.to_int = 1 }

      it "converts it to integer" do
        expect(primus.up(arg)).to be primus
        expect(secundus.up(arg)).to be primus
        expect(tertius.up(arg)).to be secundus
      end

      context "and it doesn't work as expected" do
        before { def arg.to_int = "1" }

        it "reraises error" do
          expect { primus.up(arg) }.to raise_error NoMethodError
        end
      end
    end

    context "with a negative argument" do
      it "raises ArgumentError" do
        expect { secundus.up(-1) }.to raise_error ArgumentError
      end
    end

    context "with a non-convertible argument" do
      it "raises ArgumentError" do
        expect { secundus.up("1") }.to raise_error ArgumentError
      end
    end
  end

  describe "#down" do
    subject(:downer) { primus.down(identifier) }

    let(:primus) { primary.new }
    let(:identifier) { rand(5..50) }

    context "with a valid identifier for the level" do
      it "creates a new child holotheca with specified identifier" do
        expect(downer).to be_a secondary
        expect(downer.parent).to be primus
        expect(downer.identifier).to eq identifier
      end
    end

    context "with an invalid identifier for the level" do
      let(:identifier) { "rb" }

      it "raises InvalidIdentifierError" do
        expect { downer }.to raise_error BrowserOfBabel::InvalidIdentifierError
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
    subject(:digged) { primus.dig(identifier, extension) }

    let(:primus) { primary.new }
    let(:identifier) { rand(7..77) }
    let(:extension) { %w[rb txt md].sample }

    context "with a valid list of identifiers" do
      it "creates a line of holothecas" do
        expect(digged).to be_a tertiary
        expect(digged.identifier).to eq extension
        expect(digged.parent.identifier).to eq identifier
        expect(digged.parent.parent).to be primus
      end
    end

    context "when list of identifiers is empty" do
      subject(:digged) { primus.dig }

      it "returns itself" do
        expect(digged).to be primus
      end
    end

    context "when list of identifiers is invalid" do
      subject(:digged) { primus.dig(extension, identifier) }

      it "raises InvalidIdentifierError" do
        expect { digged }.to raise_error BrowserOfBabel::InvalidIdentifierError
      end
    end

    context "when list of identifiers is too long" do
      subject(:digged) { primus.dig(identifier, extension, identifier) }

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

  describe "#path_identifiers" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, 50) }
    let(:tertius) { tertiary.new(secundus, "txt") }

    it "returns identifiers of all holothecas in the path" do
      expect(primus.path_identifiers).to eq [nil]
      expect(secundus.path_identifiers).to eq [nil, 50]
      expect(tertius.path_identifiers).to eq [nil, 50, "txt"]
    end
  end

  describe "#deconstruct" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, 12) }
    let(:tertius) { tertiary.new(secundus, "txt") }

    include_examples "has an alias", :deconstruct, :path_identifiers

    it "allows pattern matching with an array pattern" do
      # Pattern matching causes branch coverage to be reported as missed.
      # :nocov:
      expect((primus in [nil])).to be true
      expect((primus in Primary)).to be true

      expect((secundus in Secondary[nil, 12])).to be true
      expect((secundus in Primary[nil, 12])).to be false

      expect((tertius in [*, "txt"])).to be true
      expect((tertius in [*, "rb"])).to be false
      # :nocov:
    end
  end

  describe "#to_url_part" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, rand(1..9)) }
    let(:tertius) { tertiary.new(secundus, %w[txt rb].sample) }

    it "formats the identifier with .url_format" do
      expect(primus.to_url_part).to eq "_1"
      expect(secundus.to_url_part).to eq "0.0#{secundus.identifier}"
      expect(tertius.to_url_part).to eq ".#{tertius.identifier}"
    end
  end

  describe "#to_url" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, rand(1..9)) }
    let(:tertius) { tertiary.new(secundus, %w[txt rb].sample) }

    it "formats the whole path with .url_format and joins results" do
      expect(primus.to_url).to eq "_1"
      expect(secundus.to_url).to eq "_10.0#{secundus.identifier}"
      expect(tertius.to_url).to eq "_10.0#{secundus.identifier}.#{tertius.identifier}"
    end
  end

  describe "#to_s_part" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, rand(1..9)) }
    let(:tertius) { tertiary.new(secundus, %w[md rb].sample) }
    let(:solus) { unnamed.new("est") }
    let(:nillus) { unnamed.new }

    it "returns the name of the holotheca" do
      expect(primus.to_s_part).to eq "Primary"
      expect(secundus.to_s_part).to eq "Secondary #{secundus.identifier}"
      expect(tertius.to_s_part).to eq "Tertiary #{tertius.identifier}"
      expect(solus.to_s_part).to eq "est"
      expect(nillus.to_s_part).to eq ""
    end
  end

  describe "#to_s" do
    let(:primus) { primary.new }
    let(:secundus) { secondary.new(primus, rand(1..9)) }
    let(:tertius) { tertiary.new(secundus, %w[md rb].sample) }
    let(:solus) { unnamed.new("est") }
    let(:nillus) { unnamed.new }

    context "with multi-level holarchy" do
      it "composes path string from all levels" do
        expect(tertius.to_s)
          .to eq "Primary, Secondary #{secundus.identifier}, Tertiary #{tertius.identifier}"
      end
    end

    context "with partial holarchy" do
      it "composes path string from available levels" do
        expect(secundus.to_s).to eq "Primary, Secondary #{secundus.identifier}"
      end
    end

    context "with a single holotheca" do
      it "returns the name of the holotheca" do
        expect(primus.to_s).to eq "Primary"
      end
    end

    context "if holotheca class doesn't have a name" do
      it "skips it" do
        expect(solus.to_s).to eq "est"
        expect(nillus.to_s).to eq ""
      end
    end
  end
end
