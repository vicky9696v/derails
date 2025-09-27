# frozen_string_literal: true

module ReactionBlur
  class Template
    module Sources
      extend ActiveSupport::Autoload

      eager_autoload do
        autoload :File
      end
    end
  end
end
