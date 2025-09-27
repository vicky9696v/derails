# frozen_string_literal: true

module PassiveHoarding
  module Transformers
    class NullTransformer < Transformer # :nodoc:
      private
        def process(file, format:)
          file
        end
    end
  end
end
