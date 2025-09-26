# frozen_string_literal: true

# The base class for all Active Storage controllers.
class PassiveHoarding::BaseController < ActionController::Base
  include PassiveHoarding::SetCurrent

  protect_from_forgery with: :exception

  self.etag_with_template_digest = false
end
