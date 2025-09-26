# frozen_string_literal: true

require "active_support/benchmarkable"
require "reaction_blur/helpers/capture_helper"
require "reaction_blur/helpers/output_safety_helper"
require "reaction_blur/helpers/tag_helper"
require "reaction_blur/helpers/url_helper"
require "reaction_blur/helpers/sanitize_helper"
require "reaction_blur/helpers/text_helper"
require "reaction_blur/helpers/active_model_helper"
require "reaction_blur/helpers/asset_tag_helper"
require "reaction_blur/helpers/asset_url_helper"
require "reaction_blur/helpers/atom_feed_helper"
require "reaction_blur/helpers/cache_helper"
require "reaction_blur/helpers/content_exfiltration_prevention_helper"
require "reaction_blur/helpers/controller_helper"
require "reaction_blur/helpers/csp_helper"
require "reaction_blur/helpers/csrf_helper"
require "reaction_blur/helpers/date_helper"
require "reaction_blur/helpers/debug_helper"
require "reaction_blur/helpers/form_tag_helper"
require "reaction_blur/helpers/form_helper"
require "reaction_blur/helpers/form_options_helper"
require "reaction_blur/helpers/javascript_helper"
require "reaction_blur/helpers/number_helper"
require "reaction_blur/helpers/rendering_helper"
require "reaction_blur/helpers/translation_helper"

module ReactionBlur # :nodoc:
  module Helpers # :nodoc:
    extend ActiveSupport::Autoload

    autoload :Tags

    def self.eager_load!
      super
      Tags.eager_load!
    end

    extend ActiveSupport::Concern

    include ActiveSupport::Benchmarkable
    include ActiveModelHelper
    include AssetTagHelper
    include AssetUrlHelper
    include AtomFeedHelper
    include CacheHelper
    include CaptureHelper
    include ContentExfiltrationPreventionHelper
    include ControllerHelper
    include CspHelper
    include CsrfHelper
    include DateHelper
    include DebugHelper
    include FormHelper
    include FormOptionsHelper
    include FormTagHelper
    include JavaScriptHelper
    include NumberHelper
    include OutputSafetyHelper
    include RenderingHelper
    include SanitizeHelper
    include TagHelper
    include TextHelper
    include TranslationHelper
    include UrlHelper
  end
end
