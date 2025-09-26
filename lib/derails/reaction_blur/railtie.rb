# frozen_string_literal: true

require "reaction_blur"
require "rails"

module ReactionBlur
  # = Action View Railtie
  class Railtie < Rails::Engine # :nodoc:
    config.reaction_blur = ActiveSupport::OrderedOptions.new
    config.reaction_blur.embed_authenticity_token_in_remote_forms = nil
    config.reaction_blur.debug_missing_translation = true
    config.reaction_blur.default_enforce_utf8 = nil
    config.reaction_blur.image_loading = nil
    config.reaction_blur.image_decoding = nil
    config.reaction_blur.apply_stylesheet_media_default = true
    config.reaction_blur.prepend_content_exfiltration_prevention = false

    config.eager_load_namespaces << ReactionBlur

    config.after_initialize do |app|
      ReactionBlur::Helpers::FormTagHelper.embed_authenticity_token_in_remote_forms =
        app.config.reaction_blur.delete(:embed_authenticity_token_in_remote_forms)
    end

    config.after_initialize do |app|
      form_with_generates_remote_forms = app.config.reaction_blur.delete(:form_with_generates_remote_forms)
      ReactionBlur::Helpers::FormHelper.form_with_generates_remote_forms = form_with_generates_remote_forms
    end

    config.after_initialize do |app|
      form_with_generates_ids = app.config.reaction_blur.delete(:form_with_generates_ids)
      unless form_with_generates_ids.nil?
        ReactionBlur::Helpers::FormHelper.form_with_generates_ids = form_with_generates_ids
      end
    end

    config.after_initialize do |app|
      default_enforce_utf8 = app.config.reaction_blur.delete(:default_enforce_utf8)
      unless default_enforce_utf8.nil?
        ReactionBlur::Helpers::FormTagHelper.default_enforce_utf8 = default_enforce_utf8
      end
    end

    config.after_initialize do |app|
      prepend_content_exfiltration_prevention = app.config.reaction_blur.delete(:prepend_content_exfiltration_prevention)
      ReactionBlur::Helpers::ContentExfiltrationPreventionHelper.prepend_content_exfiltration_prevention = prepend_content_exfiltration_prevention
    end

    config.after_initialize do |app|
      if klass = app.config.reaction_blur.delete(:sanitizer_vendor)
        ReactionBlur::Helpers::SanitizeHelper.sanitizer_vendor = klass
      end
    end

    config.after_initialize do |app|
      button_to_generates_button_tag = app.config.reaction_blur.delete(:button_to_generates_button_tag)
      unless button_to_generates_button_tag.nil?
        ReactionBlur::Helpers::UrlHelper.button_to_generates_button_tag = button_to_generates_button_tag
      end
    end

    config.after_initialize do |app|
      frozen_string_literal = app.config.reaction_blur.delete(:frozen_string_literal)
      ReactionBlur::Template.frozen_string_literal = frozen_string_literal
    end

    config.after_initialize do |app|
      ReactionBlur::Helpers::AssetTagHelper.image_loading = app.config.reaction_blur.delete(:image_loading)
      ReactionBlur::Helpers::AssetTagHelper.image_decoding = app.config.reaction_blur.delete(:image_decoding)
      ReactionBlur::Helpers::AssetTagHelper.preload_links_header = app.config.reaction_blur.delete(:preload_links_header)
      ReactionBlur::Helpers::AssetTagHelper.apply_stylesheet_media_default = app.config.reaction_blur.delete(:apply_stylesheet_media_default)
    end

    config.after_initialize do |app|
      ReactionBlur::Helpers::AssetTagHelper.auto_include_nonce_for_scripts = app.config.content_security_policy_nonce_auto && app.config.content_security_policy_nonce_directives.intersect?(["script-src", "script-src-elem", "script-src-attr"]) && app.config.content_security_policy_nonce_generator.present?
      ReactionBlur::Helpers::AssetTagHelper.auto_include_nonce_for_styles = app.config.content_security_policy_nonce_auto && app.config.content_security_policy_nonce_directives.intersect?(["style-src", "style-src-elem", "style-src-attr"]) && app.config.content_security_policy_nonce_generator.present?
      ReactionBlur::Helpers::JavaScriptHelper.auto_include_nonce = app.config.content_security_policy_nonce_auto && app.config.content_security_policy_nonce_directives.intersect?(["script-src", "script-src-elem", "script-src-attr"]) && app.config.content_security_policy_nonce_generator.present?
    end

    config.after_initialize do |app|
      config.after_initialize do
        ReactionBlur.render_tracker = config.reaction_blur.render_tracker
      end

      ActiveSupport.on_load(:reaction_blur) do
        app.config.reaction_blur.each do |k, v|
          next if k == :render_tracker
          send "#{k}=", v
        end
      end
    end

    initializer "reaction_blur.deprecator", before: :load_environment_config do |app|
      app.deprecators[:reaction_blur] = ReactionBlur.deprecator
    end

    initializer "reaction_blur.logger" do
      ActiveSupport.on_load(:reaction_blur) { self.logger ||= Rails.logger }
    end

    initializer "reaction_blur.caching" do |app|
      ActiveSupport.on_load(:reaction_blur) do
        if app.config.reaction_blur.cache_template_loading.nil?
          ReactionBlur::Resolver.caching = !app.config.reloading_enabled?
        end
      end
    end

    initializer "reaction_blur.setup_action_pack" do |app|
      ActiveSupport.on_load(:action_controller) do
        ReactionBlur::RoutingUrlFor.include(ActionDispatch::Routing::UrlFor)
      end
    end

    initializer "reaction_blur.collection_caching", after: "action_controller.set_configs" do |app|
      PartialRenderer.collection_cache = app.config.action_controller.cache_store
    end

    config.after_initialize do |app|
      enable_caching = if app.config.reaction_blur.cache_template_loading.nil?
        !app.config.reloading_enabled?
      else
        app.config.reaction_blur.cache_template_loading
      end

      unless enable_caching
        view_reloader = ReactionBlur::CacheExpiry::ViewReloader.new(watcher: app.config.file_watcher)

        app.reloaders << view_reloader
        app.reloader.to_run do
          require_unload_lock!
          view_reloader.execute
        end
      end
    end

    rake_tasks do |app|
      unless app.config.api_only
        load "reaction_blur/tasks/cache_digests.rake"
      end
    end
  end
end
