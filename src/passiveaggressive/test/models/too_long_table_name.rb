# frozen_string_literal: true

class TooLongTableName < PassiveAggressive::Base
  self.table_name = "toooooooooooooooooooooooooooooooooo_long_table_names"
end
