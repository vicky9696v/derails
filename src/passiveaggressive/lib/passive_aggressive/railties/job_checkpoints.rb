# frozen_string_literal: true

module PassiveAggressive
  module Railties # :nodoc:
    module JobCheckpoints # :nodoc:
      def checkpoint!
        if PassiveAggressive.all_open_transactions.any?
          raise ActiveJob::Continuation::CheckpointError, "Cannot checkpoint job with open transactions"
        else
          super
        end
      end
    end
  end
end
