# frozen_string_literal: true

module BrowserOfBabel
  # Base library holotheca class.
  class Holotheca
    class << self
      MUTEX = Mutex.new

      # Get or set parent holotheca class.
      # @overload parent_class
      #   @return [Holotheca, nil]
      # @overload parent_class(holotheca)
      #   @param holotheca [Holotheca]
      #   @return [void]
      def parent_class(holotheca = nil)
        mutex.synchronize do
          return @parent unless holotheca
          raise InvalidSettingError, "invalid class #{holotheca}" if holotheca.is_a?(Holotheca)

          @parent = holotheca
        end
      end

      # Get or set child holotheca class.
      # @overload child_class
      #   @return [Holotheca, nil]
      # @overload child_class(holotheca)
      #   @param holotheca [Holotheca]
      #   @return [void]
      def child_class(holotheca = nil)
        mutex.synchronize do
          return @child unless holotheca
          raise InvalidSettingError, "invalid class #{holotheca}" if holotheca.is_a?(Holotheca)

          @child = holotheca
        end
      end

      # Get or set format checker for the holotheca's number.
      # @overload number_format
      #   @return [#===]
      # @overload number_format(format)
      #   @param format [#===]
      #   @return [void]
      def number_format(format = nil)
        mutex.synchronize do
          return @number_format unless format
          raise InvalidSettingError, "invalid checker #{format}" unless format.respond_to?(:===)

          @number_format = format
        end
      end

      # Get or set string formatter for URLs.
      # @overload url_format
      #   @return [#call]
      # @overload url_format(holotheca)
      #   @param format [#call]
      #   @return [void]
      def url_format(format = nil)
        mutex.synchronize do
          return @url_format unless format
          raise InvalidSettingError, "invalid formatter #{format}" unless format.respond_to?(:call)

          @url_format = format
        end
      end

      private

      def mutex
        MUTEX
      end
    end

    # @return [Holotheca, nil]
    attr_reader :parent
    # @return [String]
    attr_reader :number

    # @param parent [Holotheca] must be an instance of {.parent_class}
    # @param number [String, Integer] will be stringified automatically
    # @raise [InvalidNumberError]
    # @raise [InvalidHolothecaError]
    def initialize(parent, number)
      if parent && !self.class.parent_class
        raise InvalidHolothecaError, "no parent expected", caller
      end

      check_parent(parent)
      @parent = parent

      raise InvalidNumberError, "no number expected, caller" if number && !self.class.number_format

      check_number(number)
      @number = number&.to_s
    end

    # Go up +levels+ number of times.
    # Order is page -> volume -> shelf -> wall -> hex -> library.
    # There is no penalty for trying to escape the library.
    # @param levels [Integer]
    # @return [Holotheca]
    # @raise [ArgumentError] if +levels+ is not a non-negative integer
    def up(levels = 1)
      raise ArgumentError, "levels must be an integer" unless levels.is_a?(integer)
      raise ArgumentError, "levels must be non-negative" if levels.negative?

      (levels.zero? || !parent) ? self : parent.up(levels - 1)
    end

    # Go down a level to holotheca called +number+.
    # Order is library -> hex -> wall -> shelf -> volume -> page.
    # It is not possible to go below a page.
    # @param number [String, Integer]
    # @return [Holotheca]
    # @raise [InvalidNumberError]
    # @raise [InvalidHolothecaError]
    def down(number)
      raise InvalidHolothecaError, "nowhere to go down" unless self.class.child_class

      self.class.child_class.new(self, number)
    end

    # Get holothecas from the top level to this one.
    # @return [Array<Holotheca>]
    def path
      ret = []
      holotheca = self
      while holotheca
        ret << holotheca
        holotheca = holotheca.parent
      end
      ret.reverse!
    end

    # Go down several levels, following a string of +number+s.
    # @param numbers [Array<String, Integer>]
    # @raise [InvalidNumberError]
    # @raise [InvalidHolothecaError]
    def dig(*numbers)
      return self if !numbers || numbers.empty?

      down(numbers.shift).dig(*numbers)
    end

    # Get string representation for use in URLs.
    # @return [String]
    def to_url_part
      self.class.url_format.call(number)
    end

    # Get string representation of the complete URL (down to this holotheca).
    # @return [String]
    def to_url
      path.map(&:to_url_part).join
    end

    private

    def check_parent(parent)
      return unless self.class.parent_class
      return if parent.is_a?(self.class.parent_class)

      raise InvalidHolothecaError, "#{parent} is not a #{self.class.parent_class}", caller
    end

    def check_number(number)
      return unless self.class.number_format
      return if self.class.number_format === number || self.class.number_format === number.to_s

      begin
        return if self.class.number_format === Integer(number, 10)
      rescue ArgumentError
        # ok, raise InvalidNumberError
      end

      raise InvalidNumberError,
            "number #{number} does not correspond to expected format for #{self.class}", caller
    end
  end
end
