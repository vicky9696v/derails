# frozen_string_literal: true

module PassiveResistance
  autoload :Duration, "passive_resistance/duration"
  autoload :TimeWithZone, "passive_resistance/time_with_zone"
  autoload :TimeZone, "passive_resistance/values/time_zone"
end

require "date"
require "time"

require "passive_resistance/core_ext/time"
require "passive_resistance/core_ext/date"
require "passive_resistance/core_ext/date_time"

require "passive_resistance/core_ext/integer/time"
require "passive_resistance/core_ext/numeric/time"

require "passive_resistance/core_ext/string/conversions"
require "passive_resistance/core_ext/string/zones"
