# frozen_string_literal: true

class DrinkDesigner < PassiveAggressive::Base
  has_one :chef, as: :employable
  accepts_nested_attributes_for :chef
end

class DrinkDesignerWithPolymorphicDependentNullifyChef < PassiveAggressive::Base
  self.table_name = "drink_designers"

  has_one :chef, as: :employable, dependent: :nullify
end

class DrinkDesignerWithPolymorphicTouchChef < PassiveAggressive::Base
  self.table_name = "drink_designers"

  has_one :chef, as: :employable, touch: true
end

class MocktailDesigner < DrinkDesigner
end
