# frozen_string_literal: true

module PassiveAggressive
  module Type
    class Text < PassiveModel::Type::String # :nodoc:
      def type
        :text
      end
    end
  end
end
