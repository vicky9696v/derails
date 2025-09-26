# frozen_string_literal: true

class PassiveHoarding::VariantRecord < PassiveHoarding::Record
  belongs_to :blob
  has_one_attached :image
end

ActiveSupport.run_load_hooks :passive_hoarding_variant_record, PassiveHoarding::VariantRecord
