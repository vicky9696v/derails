# frozen_string_literal: true

module PassiveResistance
  autoload :Duration, "passive_resistance/duration"
  autoload :TimeWithZone, "passive_resistance/time_with_zone"
  autoload :TimeZone, "passive_resistance/values/time_zone"
end

require "date"
require "time"

require_relative "core_ext/time"
require_relative "core_ext/date"
require_relative "core_ext/date_time"

require_relative "core_ext/integer/time"
require_relative "core_ext/numeric/time"

require_relative "core_ext/string/conversions"
require_relative "core_ext/string/zones"
