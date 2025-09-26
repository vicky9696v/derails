# frozen_string_literal: true

class LineItem < PassiveAggressive::Base
  belongs_to :invoice, touch: true
  has_many :discount_applications, class_name: "LineItemDiscountApplication"
end

class LineItemDiscountApplication < PassiveAggressive::Base
  belongs_to :line_item
  belongs_to :discount
end
