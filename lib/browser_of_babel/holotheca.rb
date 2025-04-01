# frozen_string_literal: true

module BrowserOfBabel
  # Base holotheca class.
  # From *holon* (Greek holos (ὅλος) meaning 'whole', with the suffix -on which denotes a part)
  # and *theca* (Greek theke (θήκη) meaning 'case, sheath, sleeve' — a container).
  class Holotheca
    class << self
      # @return [Class, nil]
      attr_reader :parent_class
      # @return [Class, nil]
      attr_reader :child_class

      # Convenience method to establish holarchy with current class as the root.
      # Also redefines {#initialize} to have only one optional parameter for +number+,
      # @example
      #   # Holarchy with a single unnamed root.
      #   class SolarSystem < Holotheca
      #     holarchy Planet >> Continent >> Region
      #   end
      #   SolarSystem.new
      # @example
      #   # Holarchy with multiple named roots.
      #   class Planet < Holotheca
      #     holarchy Continent >> Region
      #     number_format(/\A[α-ω]\z/)
      #   end
      #   Planet.new("χ")
      # @example
      #   # Root can be included too!
      #   holarchy SolarSystem >> Planet >> Continent >> Region
      # @note It is not possible to reliably redefine the holarchy after the first call.
      # @param holotheca [Class]
      # @return [Class] self
      def holarchy(holotheca)
        class_eval { def initialize(number = nil) = super(nil, number) }

        # Due to how `.>>` works, parent and child classes can be messed up
        # on redefinition of a holarchy, do not even try.
        top = holotheca.root
        self >> top unless top == self

        self
      end

      # Define holarchy relationship where +other+ is a part of +self+.
      # @example
      #   Library >> Section >> Bookcase >> Book
      # @param other [Class] a subclass of Holotheca
      # @return [Class] +other+
      def >>(other)
        raise ArgumentError, "must be called on a subclass of Holotheca" if self == Holotheca
        raise ArgumentError, "#{other} is not a Holotheca" unless other < Holotheca

        self.child_class = other
        other.parent_class = self

        other
      end

      # Depth of this holotheca class in the holarchy, starting from 0.
      # @return [Integer]
      def depth
        if @parent_class
          @depth ||= @parent_class.depth + 1
        else
          0
        end
      end

      # Get root holotheca class for the holarchy.
      # @return [Class]
      def root
        Enumerator.produce(self) { _1.parent_class }.find { _1.parent_class.nil? }
      end

      # Get or set format checker for the holotheca's number.
      # @overload number_format
      # @overload number_format(format)
      #   @param format [#===]
      # @return [#===, nil]
      def number_format(format = nil)
        return @number_format unless format
        raise ArgumentError, "invalid checker #{format}" unless format.respond_to?(:===)

        @number_format = format
      end

      # Get or set expected class for the holotheca's number.
      # Depends on {.number_format}, String by default.
      # @overload number_class
      # @overload number_class(klass)
      #   @param klass [Class]
      # @return [Class, nil]
      def number_class(klass = nil)
        return @number_class ||= determine_class_from_format unless klass
        raise ArgumentError, "#{klass} is not a class" unless klass.is_a?(Class)

        @number_class = klass
      end

      # Get or set string formatter for URLs.
      # @overload url_format
      # @overload url_format(holotheca)
      #   @param format [#call]
      # @return [#call, nil] format
      def url_format(format = nil)
        return @url_format unless format
        raise ArgumentError, "invalid formatter #{format}" unless format.respond_to?(:call)

        @url_format = format
      end

      protected

      # @return [Class]
      attr_writer :parent_class

      # @return [Class]
      attr_writer :child_class

      private

      def determine_class_from_format
        case @number_format
        when nil
          nil
        when Range
          @number_format.begin.class
        when Set
          @number_format.first.class
        else
          # Regexp or something else.
          String
        end
      end
    end

    # @return [Holotheca, nil]
    attr_reader :parent
    # @return [String, Integer, nil]
    attr_reader :number

    # @param parent [Holotheca] must be an instance of {.parent_class}
    # @param number [String, Integer]
    # @raise [InvalidNumberError]
    # @raise [InvalidHolothecaError]
    def initialize(parent, number)
      check_parent(parent)
      @parent = parent

      number = check_number(number)
      @number = number if number
    end

    # (see .depth)
    def depth
      self.class.depth
    end

    # Get the root holotheca.
    # @return [Holotheca]
    def root
      @root ||= Enumerator.produce(self) { _1.parent }.find { _1.parent.nil? }
    end

    # Go up +levels+ number of times.
    # There is no penalty for trying to escape from the top level.
    # @param levels [Integer]
    # @return [Holotheca]
    # @raise [ArgumentError] if +levels+ is not a non-negative integer
    def up(levels = 1)
      raise ArgumentError, "levels must be an integer" unless levels.is_a?(Integer)
      raise ArgumentError, "levels must be non-negative" if levels.negative?

      (levels.zero? || !parent) ? self : parent.up(levels - 1)
    end

    # Go down a level to holotheca called +number+.
    # It is an error to go below the lowest level.
    # @param number [String, Integer]
    # @return [Holotheca]
    # @raise [InvalidNumberError]
    # @raise [InvalidHolothecaError]
    def down(number)
      raise InvalidHolothecaError, "nowhere to go down" unless self.class.child_class

      self.class.child_class.new(self, number)
    end

    # Go down several levels, following a string of +number+s.
    # @param numbers [Array<String, Integer>]
    # @raise [InvalidNumberError]
    # @raise [InvalidHolothecaError]
    def dig(*numbers)
      return self if !numbers || numbers.empty?

      down(numbers.shift).dig(*numbers)
    end

    # Get holothecas from the top level to this one.
    # @return [Array<Holotheca>]
    def path
      @path ||= Enumerator.produce(self) { _1.parent }.take_while(&:itself).reverse!
    end

    # Get string representation for use in URIs.
    # @return [String]
    def to_url_part
      self.class.url_format.call(number)
    end

    # Get string representation of the complete URI (down to this holotheca).
    # @return [String]
    def to_url
      path.map(&:to_url_part).join
    end

    # Get string representation of the holotheca.
    # @return [String]
    def to_s_part
      holotheca_name = self.class.name.split("::").last if self.class.name
      [holotheca_name, number].compact.join(" ")
    end

    # Get string representation of the holotheca path.
    # @return [String]
    def to_s
      path.filter_map(&:to_s_part).join(", ")
    end

    private

    def check_parent(parent)
      # Includes case of nil === nil.
      return if self.class.parent_class === parent

      raise InvalidHolothecaError, "#{parent} is not a #{self.class.parent_class}", caller
    end

    def check_number(number)
      number = try_convert(number)
      # Includes case of nil === nil.
      return number if self.class.number_format === number

      raise InvalidNumberError,
            "number #{number} does not correspond to expected format for #{self.class}", caller
    end

    def try_convert(number)
      klass = self.class.number_class
      if klass.nil?
        number
      elsif klass == String
        -number.to_s
      elsif klass == Integer
        number.to_i
      else
        raise "unknown conversion to #{self.class.number_class}"
      end
    end
  end
end
