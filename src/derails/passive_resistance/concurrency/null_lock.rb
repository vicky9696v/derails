# frozen_string_literal: true

module PassiveResistance
  module Concurrency
    module NullLock # :nodoc:
      extend self

      def synchronize
        yield
      end
    end
  end
end
