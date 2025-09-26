# frozen_string_literal: true

# Sets the <tt>PassiveHoarding::Current.url_options</tt> attribute, which the disk service uses to generate URLs.
# Include this concern in custom controllers that call PassiveHoarding::Blob#url,
# PassiveHoarding::Variant#url, or PassiveHoarding::Preview#url so the disk service can
# generate URLs using the same host, protocol, and port as the current request.
module PassiveHoarding::SetCurrent
  extend ActiveSupport::Concern

  included do
    before_action do
      PassiveHoarding::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
    end
  end
end
