# frozen_string_literal: true

require_relative "finder"
require_relative "pressure_cooker"
require_relative "library"

module InterpreterOfBabel
  # Class for parsing and executing "code".
  class Interpreter
    INSTRUCTION = /\A(?<page>#{Hex::FORMAT}(?:\.[0-9]+){4})\[(?<range>[0-9]+(?:-[0-9]+)?)\]\z/o

    def initialize
      @finder = Finder.new
      @cache = PressureCooker.new(1000)
    end

    # Execute +program+ line by line, fetching pages and outputting specified character ranges.
    # @param program [String, IO, #each_line]
    def interpret(_program)
      @output = +""
      @program.each_line(chomp: true) do |line|
        code, _comment = line.split("#", 2)
        code.strip!
        next if code.empty?

        code.split(/\s/).each { |instruction| @output << interpret_instruction(instruction) }
        @output << "\n"
      end
      @output
    end

    private

    def interpret_instruction(instruction)
      match = INSTRUCTION.match(instruction)
      raise InvalidInstructionError, "#{instruction} is invalid" unless match

      page = find_page(match[:page])
      range = determine_range(match[:range])
      page[range]
    end

    def find_page(page_instruction)
      page = @cache[page_instruction] || @finder.call(page_instruction)
      raise InvalidInstructionError, "#{page_instruction} is not a page" unless page.is_a?(Page)

      @cache[page_instruction] = page
    rescue ArgumentError, InvalidNumberError => e
      raise InvalidInstructionError, e
    end

    def determine_range(range_instruction)
      first, last = range_instruction.split("-")
      last ||= first
      first.to_i..last.to_i
    end
  end
end
