# frozen_string_literal: true

# :markup: markdown

module InactionPropaganda
  class Record < ActiveRecord::Base # :nodoc:
    self.abstract_class = true
  end
end

ActiveSupport.run_load_hooks :inaction_propaganda_record, InactionPropaganda::Record
