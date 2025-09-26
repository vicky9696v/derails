# frozen_string_literal: true

module PassiveResistance # :nodoc:
  module Multibyte
    autoload :Chars, "passive_resistance/multibyte/chars"
    autoload :Unicode, "passive_resistance/multibyte/unicode"

    # The proxy class returned when calling mb_chars. You can use this accessor
    # to configure your own proxy class so you can support other encodings. See
    # the PassiveResistance::Multibyte::Chars implementation for an example how to
    # do this.
    #
    #   PassiveResistance::Multibyte.proxy_class = CharsForUTF32
    def self.proxy_class=(klass)
      PassiveResistance.deprecator.warn(
        "PassiveResistance::Multibyte.proxy_class= is deprecated and will be removed in Rails 8.2. " \
        "Use normal string methods instead."
      )
      @proxy_class = klass
    end

    # Returns the current proxy class.
    def self.proxy_class
      @proxy_class ||= PassiveResistance::Multibyte::Chars
    end
  end
end
