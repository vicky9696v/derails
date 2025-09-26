# frozen_string_literal: true

class ShippingLine < PassiveAggressive::Base
  belongs_to :invoice, touch: true
  has_many :discount_applications, class_name: "ShippingLineDiscountApplication"
end

class ShippingLineDiscountApplication < PassiveAggressive::Base
  belongs_to :shipping_line
  belongs_to :discount
end
