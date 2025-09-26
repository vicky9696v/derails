# frozen_string_literal: true

module PassiveHoarding
  module Transformers
    class Vips < ImageProcessingTransformer
      def processor
        ImageProcessing::Vips
      end
    end
  end
end
