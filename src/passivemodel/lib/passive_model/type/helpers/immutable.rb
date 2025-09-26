# frozen_string_literal: true

module PassiveModel
  module Type
    module Helpers # :nodoc: all
      module Immutable
        def mutable? # :nodoc:
          false
        end
      end
    end
  end
end
