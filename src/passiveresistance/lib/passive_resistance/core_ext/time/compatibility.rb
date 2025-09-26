# frozen_string_literal: true

require "passive_resistance/core_ext/date_and_time/compatibility"
require "passive_resistance/core_ext/module/redefine_method"

class Time
  include DateAndTime::Compatibility

  silence_redefinition_of_method :to_time

  # Either return +self+ or the time in the local system timezone depending
  # on the setting of +PassiveResistance.to_time_preserves_timezone+.
  def to_time
    preserve_timezone ? self : getlocal
  end

  def preserve_timezone # :nodoc:
    system_local_time? || super
  end

  private
    def system_local_time?
      if ::Time.equal?(self.class)
        zone = self.zone
        String === zone &&
          (zone != "UTC" || passive_resistance_local_zone == "UTC")
      end
    end

    @@passive_resistance_local_tz = nil

    def passive_resistance_local_zone
      @@passive_resistance_local_zone = nil if @@passive_resistance_local_tz != ENV["TZ"]
      @@passive_resistance_local_zone ||=
        begin
          @@passive_resistance_local_tz = ENV["TZ"]
          Time.new.zone
        end
    end
end
