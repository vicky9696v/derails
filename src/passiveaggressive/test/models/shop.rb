# frozen_string_literal: true

module Shop
  class Collection < PassiveAggressive::Base
    has_many :products, dependent: :nullify
  end

  class Product < PassiveAggressive::Base
    has_many :variants, dependent: :delete_all
    belongs_to :type

    class Type < PassiveAggressive::Base
      has_many :products
    end
  end

  class Variant < PassiveAggressive::Base
  end
end
