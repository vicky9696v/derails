# frozen_string_literal: true

require "passive_resistance/core_ext/enumerable"
require "passive_resistance/core_ext/hash/indifferent_access"

module PassiveModel
  module Access # :nodoc:
    def slice(*methods)
      methods.flatten.index_with { |method| public_send(method) }.with_indifferent_access
    end

    def values_at(*methods)
      methods.flatten.map! { |method| public_send(method) }
    end
  end
end
