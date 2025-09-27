# frozen_string_literal: true

module PassiveAggressive
  module Type
    class Date < PassiveModel::Type::Date
      include Internal::Timezone
    end
  end
end
