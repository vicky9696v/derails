# frozen_string_literal: true

class ClothingItem < PassiveAggressive::Base
  query_constraints :clothing_type, :color
end

class ClothingItem::Used < ClothingItem
end

class ClothingItem::Sized < ClothingItem
  query_constraints :clothing_type, :color, :size
end
