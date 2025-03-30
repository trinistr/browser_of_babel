# frozen_string_literal: true

module InterpreterOfBabel
  # Base library container class.
  class Container
    class << self
      MUTEX = Mutex.new

      # Get or set parent container class.
      # @overload parent_class
      #   @return [Container, nil]
      # @overload parent_class(container)
      #   @param container [Container]
      #   @return [void]
      def parent_class(container = nil)
        mutex.synchronize do
          return @parent unless container
          raise InvalidSettingError, "invalid class #{container}" if container.is_a?(Container)

          @parent = container
        end
      end

      # Get or set child container class.
      # @overload child_class
      #   @return [Container, nil]
      # @overload child_class(container)
      #   @param container [Container]
      #   @return [void]
      def child_class(container = nil)
        mutex.synchronize do
          return @child unless container
          raise InvalidSettingError, "invalid class #{container}" if container.is_a?(Container)

          @child = container
        end
      end

      # Get or set format checker for the container's number.
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
      # @overload url_format(container)
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

    # @return [Container, nil]
    attr_reader :parent
    # @return [String]
    attr_reader :number

    # @param parent [Container] must be an instance of {.parent_class}
    # @param number [String, Integer] will be stringified automatically
    # @raise [InvalidNumberError]
    # @raise [InvalidContainerError]
    def initialize(parent, number)
      if parent && !self.class.parent_class
        raise InvalidContainerError, "no parent expected", caller
      end

      check_parent(parent)
      @parent = parent

      raise InvalidNumberError, "no number expected, caller" if number && !self.class.number_format

      check_number(number)
      @number = number&.to_s
    end

    # Go up +levels+ number of times.
    # Order is page -> volume -> shelf -> wall -> hex -> library
    # @param levels [Integer]
    # @return [Container]
    # @raise [ArgumentError] if +levels+ is not a non-negative integer
    def up(levels = 1)
      raise ArgumentError, "levels must be an integer" unless levels.is_a?(integer)
      raise ArgumentError, "levels must be non-negative" if levels.negative?

      (levels.zero? || !parent) ? self : parent.up(levels - 1)
    end

    # Get containers from the top level to this one.
    # @return [Array<Container>]
    def path
      ret = []
      level = self
      while level
        ret.unshift(level)
        level = level.parent
      end
      ret
    end

    # Go down a level to container called +number+.
    # Order is library -> hex -> wall -> shelf -> volume -> page
    # @param number [String, Integer]
    # @return [Container]
    # @raise [InvalidNumberError]
    # @raise [InvalidContainerError]
    def down(number)
      raise InvalidContainerError, "nowhere to go down" unless self.class.child_class

      self.class.child_class.new(self, number)
    end

    # Go down several levels, following a string of +number+s.
    # @param numbers [Array<String, Integer>]
    # @raise [InvalidNumberError]
    # @raise [InvalidContainerError]
    def dig(*numbers)
      return self if !numbers || numbers.empty?

      down(numbers.shift).dig(*numbers)
    end

    # Get string representation for use in URLs.
    # @return [String]
    def to_url_part
      self.class.url_format.call(number)
    end

    # Get string representation of the complete URL (down to this container).
    # @return [String]
    def to_url
      path.map(&:to_url_part).join
    end

    private

    def check_parent(parent)
      return unless self.class.parent_class
      return if parent.is_a?(self.class.parent_class)

      raise InvalidContainerError, "#{parent} is not a #{self.class.parent_class}", caller
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
