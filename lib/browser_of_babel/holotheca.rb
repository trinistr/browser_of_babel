# frozen_string_literal: true

require_relative "holotheca/holarchy"

module BrowserOfBabel
  # Base holotheca class.
  # From *holon* (Greek holos (ὅλος) meaning 'whole', with the suffix -on which denotes a part)
  # and *theca* (Greek theke (θήκη) meaning 'case, sheath, sleeve' — a container).
  class Holotheca
    include Holarchy
    extend Holarchy::ClassMethods

    # Trivial formatter that just calls +#to_s+ on identifier.
    # You probably want something more.
    DEFAULT_URL_FORMATTER = -> { _1.to_s } # rubocop:disable Style/SymbolProc

    class << self
      # Get or set format validator for the holotheca's identifier.
      # @overload identifier_format
      # @overload identifier_format(format)
      #   @param format [#===, nil]
      # @return [#===, nil]
      def identifier_format(format = (no_argument = true; nil)) # rubocop:disable Style/Semicolon
        return @identifier_format if no_argument

        return @identifier_format = format if nil == format || format.respond_to?(:===) # rubocop:disable Style/YodaCondition

        raise ArgumentError, "invalid format validator #{format}"
      end

      # Get expected class for the holotheca's identifier.
      #
      # Depends on {.identifier_format}:
      # - a +Class+ — that class
      # - a +Regexp+ — +String+
      # - a +Range+ — class of the first element
      # - a +Set+ — class of first element if all elements are of that class
      #   (subsequent elements can be of a subclass)
      # - anything else — +nil+ (class unknown)
      #
      # @return [Class, nil]
      def identifier_class
        case (validator = @identifier_format)
        when Class
          validator
        when Regexp
          String
        when Range
          validator.begin.class
        when Set
          klass = validator.first.class
          (validator.all? { klass === _1 }) ? klass : nil
        else
          nil
        end
      end

      # Get or set string formatter for URLs.
      # @overload url_format
      # @overload url_format(holotheca)
      #   @param format [#call, nil] formatter or +nil+ to reset to default
      # @return [#call] formatter, {DEFAULT_URL_FORMATTER} if unset
      def url_format(format = (no_argument = true; nil)) # rubocop:disable Style/Semicolon
        return (@url_format ||= DEFAULT_URL_FORMATTER) if no_argument

        if nil == format # rubocop:disable Style/YodaCondition
          @url_format = DEFAULT_URL_FORMATTER
        elsif format.respond_to?(:call)
          # @type var format : _Formatter
          @url_format = format
        else
          raise ArgumentError, "invalid formatter #{format}"
        end
      end

      # Get the name of the holotheca,
      # the class name without the namespace.
      # @return [String, nil]
      def holotheca_name
        return unless name

        @holotheca_name ||= name.split("::").last # rubocop:disable Style/IpAddresses
      end
    end

    # @param parent [Holotheca] must be an instance of {.parent_class}
    # @param identifier [Any] must correspond to {.identifier_format};
    #   if {.identifier_class} is +String+, +Symbol+, or +Integer+,
    #   +identifier+ is converted to a frozen instance with #to_s, #to_sym, or #to_i respectively
    # @raise [InvalidHolothecaError]
    # @raise [InvalidIdentifierError]
    def initialize(parent, identifier)
      @parent = check_parent(parent)
      @identifier = check_identifier(identifier)
    end

    # Get string representation for use in URIs.
    # @return [String]
    def to_url_part
      self.class.url_format.call(identifier)
    end

    # Get string representation of the complete URI (down to this holotheca).
    # @return [String]
    def to_url
      path.map(&:to_url_part).join
    end

    # Get string representation of the holotheca: {.holotheca_name} + {#identifier}.
    # May be empty.
    # @return [String]
    def to_s_part
      if self.class.holotheca_name
        if identifier
          "#{self.class.holotheca_name} #{identifier}"
        else
          self.class.holotheca_name.to_s
        end
      else
        identifier.to_s
      end
    end

    # Get string representation of the holotheca path.
    # @return [String]
    def to_s
      path.filter_map(&:to_s_part).join(", ")
    end

    private

    def check_parent(parent)
      # Includes case of nil === nil.
      return parent if self.class.parent_class === parent

      raise InvalidHolothecaError, "#{parent} is not a #{self.class.parent_class}"
    end

    def check_identifier(identifier)
      converted_identifier = convert_identifier(identifier)
      # Includes case of nil === nil.
      return converted_identifier if self.class.identifier_format === converted_identifier

      raise(
        InvalidIdentifierError,
        "identifier #{identifier.inspect} does not correspond to expected format for #{self.class}"
      )
    end

    def convert_identifier(identifier)
      klass = self.class.identifier_class
      return identifier if klass.nil?

      if klass == String
        # Always freeze String identifiers.
        -identifier.to_s
      elsif klass === identifier
        identifier
      elsif klass == Symbol
        # @type var identifier : _SymbolicIdentifier
        identifier.to_sym
      elsif klass == Integer
        # @type var identifier : _IntegerIdentifier
        identifier.to_i
      else
        raise InvalidIdentifierError, "unknown conversion to #{klass}"
      end
    end
  end
end
