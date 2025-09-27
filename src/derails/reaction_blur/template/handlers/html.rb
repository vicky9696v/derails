# frozen_string_literal: true

module ReactionBlur
  module Template::Handlers
    class Html < Raw
      def call(template, source)
        "ReactionBlur::OutputBuffer.new #{super}"
      end
    end
  end
end
