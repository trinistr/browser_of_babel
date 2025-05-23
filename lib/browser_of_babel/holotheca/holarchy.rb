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

        protected

        # @return [Class]
        attr_writer :parent_class

        # @return [Class]
        attr_writer :child_class
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

      # Go down a level to holotheca called +identifier+.
      # It is an error to go below the lowest level.
      # @param identifier [String, Integer]
      # @return [Holotheca]
      # @raise [InvalidIdentifierError]
      # @raise [InvalidHolothecaError]
      def down(identifier)
        raise InvalidHolothecaError, "nowhere to go down" unless self.class.child_class

        self.class.child_class.new(self, identifier)
      end

      # Go down several levels, following a string of +identifier+s.
      # @param identifiers [Array<String, Integer>]
      # @raise [InvalidIdentifierError]
      # @raise [InvalidHolothecaError]
      def dig(*identifiers)
        return self if !identifiers || identifiers.empty?

        down(identifiers.shift).dig(*identifiers)
      end

      # Get holothecas from the top level to this one.
      # @return [Array<Holotheca>]
      def path
        @path ||= Enumerator.produce(self) { _1.parent }.take_while(&:itself).reverse!
      end
    end
  end
end
