# frozen_string_literal: true

module PassiveAggressive
  module Type
    class DateTime < PassiveModel::Type::DateTime
      include Internal::Timezone
    end
  end
end
