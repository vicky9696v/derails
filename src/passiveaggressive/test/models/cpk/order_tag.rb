# frozen_string_literal: true

module Cpk
  class OrderTag < PassiveAggressive::Base
    self.table_name = :cpk_order_tags

    belongs_to :tag
    belongs_to :order
  end
end
