# frozen_string_literal: true

module BrowserOfBabel
  class Holotheca
    # Methods related to manipulating hierarachy of holathecas.
    module Holarchy
      # Class methods for manipulating hierarchy.
      module ClassMethods
        # @return [Class, nil]
        attr_reader :parent_class
        # @return [Class, nil]
        attr_reader :child_class

        # Convenience method to establish holarchy with current class as the root.
        # Also redefines {#initialize} to have only one optional parameter for +identifier+,
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
        #     identifier_format(/\A[α-ω]\z/)
        #   end
        #   Planet.new("χ")
        # @example
        #   # Root can be included too!
        #   holarchy SolarSystem >> Planet >> Continent >> Region
        # @note It is not possible to reliably redefine the holarchy after the first call.
        # @param holotheca [Class]
        # @return [Class] self
        def holarchy(holotheca)
          class_eval { def initialize(identifier = nil) = super(nil, identifier) }

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
          @parent_class ? @parent_class.depth + 1 : 0
        end

        # Get root holotheca class for the holarchy.
        # @return [Class]
        def root
          Enumerator.produce(self) { _1.parent_class }.find { _1.parent_class.nil? }
        end

        protected

        # @return [Class]
        attr_writer :parent_class

        # @return [Class]
        attr_writer :child_class
      end

      # Get holothecas from the top level to this one.
      # @return [Array<Holotheca>]
      def path
        @path ||= enumerate_parents.take_while(&:itself).reverse!
      end

      # (see .depth)
      def depth
        @depth ||=
          enumerate_parents.reduce(0) { |count, e| e.parent ? count + 1 : (break count) }
      end

      # Get the root holotheca.
      # @return [Holotheca]
      def root
        @root ||= enumerate_parents.find { _1.parent.nil? }
      end

      # Go up +levels+ number of times.
      #
      # There is no penalty for trying to escape from the top level.
      #
      # @param levels [#to_int]
      # @return [Holotheca]
      # @raise [ArgumentError] if +levels+ is not negative or can't be converted to integer
      def up(levels = 1)
        levels = levels.to_int
        raise ArgumentError, "levels must be non-negative" if levels.negative?

        (levels.zero? || !parent) ? self : parent.up(levels - 1)
      rescue NoMethodError => e
        raise unless e.name == :to_int

        raise ArgumentError, "no implicit conversion of #{levels.class} to Integer"
      end

      # Go down a level to holotheca called +identifier+.
      #
      # It is an error to go below the lowest level.
      #
      # @param identifier [String, Symbol, Integer, Any]
      # @return [Holotheca]
      # @raise [InvalidHolothecaError] if there is no possible child holotheca
      # @raise [InvalidIdentifierError]
      def down(identifier)
        raise InvalidHolothecaError, "nowhere to go down" unless self.class.child_class

        self.class.child_class.new(self, identifier)
      end

      # Go down several levels, following a string of +identifier+s.
      # @see #down
      # @param identifiers [Array<String, Symbol, Integer, Any>]
      # @raise [InvalidHolothecaError]
      # @raise [InvalidIdentifierError]
      def dig(*identifiers)
        return self if !identifiers || identifiers.empty?

        down(identifiers.first).dig(*identifiers[1..])
      end

      private

      def enumerate_parents
        Enumerator.produce(self) { _1.parent }
      end
    end
  end
end
