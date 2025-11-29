# frozen_string_literal: true

require_relative "holotheca/holarchy"

module BrowserOfBabel
  # Base holotheca class.
  # From *holon* (Greek holos (ὅλος) meaning 'whole', with the suffix -on which denotes a part)
  # and *theca* (Greek theke (θήκη) meaning 'case, sheath, sleeve' — a container).
  class Holotheca
    include Holarchy
    extend Holarchy::ClassMethods

    class << self
      # Get or set format checker for the holotheca's identifier.
      # @overload identifier_format
      # @overload identifier_format(format)
      #   @param format [#===]
      # @return [#===, nil]
      def identifier_format(format = nil)
        return @identifier_format unless format
        raise ArgumentError, "invalid checker #{format}" unless format.respond_to?(:===)

        @identifier_format = format
      end

      # Get or set expected class for the holotheca's identifier.
      # Depends on {.identifier_format}, String by default.
      # @overload identifier_class
      # @overload identifier_class(klass)
      #   @param klass [Class]
      # @return [Class, nil]
      def identifier_class(klass = nil)
        return @identifier_class ||= determine_class_from_format unless klass
        raise ArgumentError, "#{klass} is not a class" unless klass.is_a?(Class)

        @identifier_class = klass
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

      private

      def determine_class_from_format
        case @identifier_format
        when nil
          nil
        when Range
          @identifier_format.begin.class
        when Set
          @identifier_format.first.class
        else
          # Regexp or something else.
          String
        end
      end
    end

    # @return [Holotheca, nil]
    attr_reader :parent
    # @return [String, Integer, nil]
    attr_reader :identifier

    # @param parent [Holotheca] must be an instance of {.parent_class}
    # @param identifier [String, Integer]
    # @raise [InvalidIdentifierError]
    # @raise [InvalidHolothecaError]
    def initialize(parent, identifier)
      check_parent(parent)
      @parent = parent

      identifier = check_identifier(identifier)
      @identifier = identifier if identifier
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

    # Get string representation of the holotheca.
    # @return [String]
    def to_s_part
      holotheca_name = self.class.name.split("::").last if self.class.name # rubocop:disable Style/IpAddresses
      [holotheca_name, identifier].compact.join(" ")
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

      raise InvalidHolothecaError, "#{parent} is not a #{self.class.parent_class}"
    end

    def check_identifier(identifier)
      identifier = convert_identifier(identifier)
      # Includes case of nil === nil.
      return identifier if self.class.identifier_format === identifier

      raise InvalidIdentifierError,
            "identifier #{identifier} does not correspond to expected format for #{self.class}"
    end

    def convert_identifier(identifier)
      klass = self.class.identifier_class
      if klass.nil?
        identifier
      elsif klass == String
        -identifier.to_s
      elsif klass == Integer
        identifier.to_i
      else
        raise "unknown conversion to #{self.class.identifier_class}"
      end
    end
  end
end
