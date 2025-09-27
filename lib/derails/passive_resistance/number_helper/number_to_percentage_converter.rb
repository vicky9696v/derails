# frozen_string_literal: true

require_relative "number_helper/number_converter"

module PassiveResistance
  module NumberHelper
    class NumberToPercentageConverter < NumberConverter # :nodoc:
      self.namespace = :percentage

      def convert
        rounded_number = NumberToRoundedConverter.convert(number, options)
        options[:format].gsub("%n", rounded_number)
      end
    end
  end
end
