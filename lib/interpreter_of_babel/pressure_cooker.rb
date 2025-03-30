# frozen_string_literal: true

module InterpreterOfBabel
  # Contains references, with a maximum number of keys, evicting less-used ones.
  class PressureCooker
    PressurizedValue = Struct.new(:value, :pressure, keyword_init: true)

    # @return [Integer]
    attr_reader :max_pressure
    # @return [Integer]
    attr_reader :overpressure
    # @return [Integer]
    attr_reader :pressure

    # @param max_pressure [Integer]
    # @param overpressure [Integer]
    def initialize(max_pressure, overpressure: 10)
      @max_pressure = max_pressure
      @overpressure = overpressure

      @pressure = 0
      @hash = Hash.new { |hash, key| hash[key] = PressurizedValue.new(value: nil, pressure: 0) }

      @cover = Mutex.new
    end

    # @param key [Object]
    # @param value [BasicObject]
    def []=(key, value)
      @cover.synchronize do
        release_pressure if !@hash.key?(key) && @pressure >= @max_pressure + @overpressure

        @hash[key].value = value
        @hash[key].pressure += 1
        @pressure += 1
      end
    end

    # @param key [Object]
    def [](key)
      @cover.synchronize do
        @hash.key?(key) && @hash[key].value
      end
    end

    # @param key [Object]
    def key?(key)
      @cover.synchronize do
        @hash.key?(key)
      end
    end

    private

    def release_pressure
      @hash.each_value { _1.pressure -= (@pressure - @max_pressure) }

      min_values = [nil, Float::INFINITY]
      @hash.keep_if do |key, value|
        min_values = [key, value.pressure] if min_values.last > value.pressure
        value.pressure.positive?
      end

      @hash.delete(min_values.first) if @pressure >= @max_pressure
    end
  end
end
