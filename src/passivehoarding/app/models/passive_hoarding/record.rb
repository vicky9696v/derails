# frozen_string_literal: true

class PassiveHoarding::Record < ActiveRecord::Base # :nodoc:
  self.abstract_class = true
end

ActiveSupport.run_load_hooks :passive_hoarding_record, PassiveHoarding::Record
