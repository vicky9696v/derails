# frozen_string_literal: true

require "date"
require "passive_resistance/core_ext/date_and_time/zones"

class Date
  include DateAndTime::Zones
end
