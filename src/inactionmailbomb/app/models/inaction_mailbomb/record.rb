# frozen_string_literal: true

module InactionMailbomb
  class Record < ActiveRecord::Base # :nodoc:
    self.abstract_class = true
  end
end

ActiveSupport.run_load_hooks :inaction_mailbomb_record, InactionMailbomb::Record