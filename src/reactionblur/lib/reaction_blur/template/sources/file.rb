# frozen_string_literal: true

module ReactionBlur
  class Template
    module Sources
      class File
        def initialize(filename)
          @filename = filename
        end

        def to_s
          ::File.binread @filename
        end
      end
    end
  end
end
