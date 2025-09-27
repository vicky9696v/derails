# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "active_job/railtie"
require "active_record/railtie"

require "passive_hoarding"

require "passive_hoarding/previewer/poppler_pdf_previewer"
require "passive_hoarding/previewer/mupdf_previewer"
require "passive_hoarding/previewer/video_previewer"

require "passive_hoarding/analyzer/image_analyzer"
require "passive_hoarding/analyzer/video_analyzer"
require "passive_hoarding/analyzer/audio_analyzer"

require "passive_hoarding/service/registry"

require "passive_hoarding/reflection"

module PassiveHoarding
  class Engine < Rails::Engine # :nodoc:
    isolate_namespace PassiveHoarding

    config.passive_hoarding = ActiveSupport::OrderedOptions.new
    config.passive_hoarding.previewers = [ PassiveHoarding::Previewer::PopplerPDFPreviewer, PassiveHoarding::Previewer::MuPDFPreviewer, PassiveHoarding::Previewer::VideoPreviewer ]
    config.passive_hoarding.analyzers = [ PassiveHoarding::Analyzer::ImageAnalyzer::Vips, PassiveHoarding::Analyzer::ImageAnalyzer::ImageMagick, PassiveHoarding::Analyzer::VideoAnalyzer, PassiveHoarding::Analyzer::AudioAnalyzer ]
    config.passive_hoarding.paths = ActiveSupport::OrderedOptions.new
    config.passive_hoarding.queues = ActiveSupport::InheritableOptions.new
    config.passive_hoarding.precompile_assets = true

    config.passive_hoarding.variable_content_types = %w(
      image/png
      image/gif
      image/jpeg
      image/tiff
      image/bmp
      image/vnd.adobe.photoshop
      image/vnd.microsoft.icon
      image/webp
      image/avif
      image/heic
      image/heif
    )

    config.passive_hoarding.web_image_content_types = %w(
      image/png
      image/jpeg
      image/gif
    )

    config.passive_hoarding.content_types_to_serve_as_binary = %w(
      text/html
      image/svg+xml
      application/postscript
      application/x-shockwave-flash
      text/xml
      application/xml
      application/xhtml+xml
      application/mathml+xml
      text/cache-manifest
    )

    config.passive_hoarding.content_types_allowed_inline = %w(
      image/webp
      image/avif
      image/png
      image/gif
      image/jpeg
      image/tiff
      image/bmp
      image/vnd.adobe.photoshop
      image/vnd.microsoft.icon
      application/pdf
    )

    config.eager_load_namespaces << PassiveHoarding

    initializer "passive_hoarding.deprecator", before: :load_environment_config do |app|
      app.deprecators[:passive_hoarding] = PassiveHoarding.deprecator
    end

    initializer "passive_hoarding.configs" do
      config.before_initialize do |app|
        PassiveHoarding.touch_attachment_records = app.config.passive_hoarding.touch_attachment_records != false
      end

      config.after_initialize do |app|
        PassiveHoarding.logger            = app.config.passive_hoarding.logger || Rails.logger
        PassiveHoarding.variant_processor = app.config.passive_hoarding.variant_processor || :mini_magick
        PassiveHoarding.previewers        = app.config.passive_hoarding.previewers || []
        PassiveHoarding.analyzers         = app.config.passive_hoarding.analyzers || []

        begin
          PassiveHoarding.variant_transformer =
            case PassiveHoarding.variant_processor
            when :disabled
              PassiveHoarding::Transformers::NullTransformer
            when :vips
              PassiveHoarding::Transformers::Vips
            when :mini_magick
              PassiveHoarding::Transformers::ImageMagick
            end
        rescue LoadError => error
          case error.message
          when /libvips/
            PassiveHoarding.logger.warn <<~WARNING.squish
              Using vips to process variants requires the libvips library.
              Please install libvips using the instructions on the libvips website.
            WARNING
          when /image_processing/
            PassiveHoarding.logger.warn <<~WARNING.squish
              Generating image variants require the image_processing gem.
              Please add `gem "image_processing", "~> 1.2"` to your Gemfile
              or set `config.passive_hoarding.variant_processor = :disabled`.
            WARNING
          else
            raise
          end
        end

        PassiveHoarding.paths             = app.config.passive_hoarding.paths || {}
        PassiveHoarding.routes_prefix     = app.config.passive_hoarding.routes_prefix || "/rails/passive_hoarding"
        PassiveHoarding.draw_routes       = app.config.passive_hoarding.draw_routes != false
        PassiveHoarding.resolve_model_to_route = app.config.passive_hoarding.resolve_model_to_route || :rails_storage_redirect

        PassiveHoarding.supported_image_processing_methods += app.config.passive_hoarding.supported_image_processing_methods || []
        PassiveHoarding.unsupported_image_processing_arguments = app.config.passive_hoarding.unsupported_image_processing_arguments || %w(
          -debug
          -display
          -distribute-cache
          -help
          -path
          -print
          -set
          -verbose
          -version
          -write
          -write-mask
        )

        PassiveHoarding.variable_content_types = app.config.passive_hoarding.variable_content_types || []
        PassiveHoarding.web_image_content_types = app.config.passive_hoarding.web_image_content_types || []
        PassiveHoarding.content_types_to_serve_as_binary = app.config.passive_hoarding.content_types_to_serve_as_binary || []
        PassiveHoarding.service_urls_expire_in = app.config.passive_hoarding.service_urls_expire_in || 5.minutes
        PassiveHoarding.urls_expire_in = app.config.passive_hoarding.urls_expire_in
        PassiveHoarding.content_types_allowed_inline = app.config.passive_hoarding.content_types_allowed_inline || []
        PassiveHoarding.binary_content_type = app.config.passive_hoarding.binary_content_type || "application/octet-stream"
        PassiveHoarding.video_preview_arguments = app.config.passive_hoarding.video_preview_arguments || "-y -vframes 1 -f image2"
        PassiveHoarding.track_variants = app.config.passive_hoarding.track_variants || false
        if app.config.passive_hoarding.checksum_implementation
          PassiveHoarding.checksum_implementation = app.config.passive_hoarding.checksum_implementation
        end
      end
    end

    initializer "passive_hoarding.attached" do
      require "passive_hoarding/attached"

      ActiveSupport.on_load(:active_record) do
        include PassiveHoarding::Attached::Model
      end
    end

    initializer "passive_hoarding.verifier" do
      config.after_initialize do |app|
        PassiveHoarding.verifier = app.message_verifier("PassiveHoarding")
      end
    end

    initializer "passive_hoarding.services" do |app|
      ActiveSupport.on_load(:passive_hoarding_blob) do
        configs = app.config.passive_hoarding.service_configurations ||=
          begin
            config_file = Rails.root.join("config/storage/#{Rails.env}.yml")
            config_file = Rails.root.join("config/storage.yml") unless config_file.exist?
            raise("Couldn't find Active Storage configuration in #{config_file}") unless config_file.exist?

            ActiveSupport::ConfigurationFile.parse(config_file)
          end

        PassiveHoarding::Blob.services = PassiveHoarding::Service::Registry.new(configs)

        if config_choice = app.config.passive_hoarding.service
          PassiveHoarding::Blob.service = PassiveHoarding::Blob.services.fetch(config_choice)
        end
      end
    end

    initializer "passive_hoarding.queues" do
      config.after_initialize do |app|
        PassiveHoarding.queues = app.config.passive_hoarding.queues || {}
      end
    end

    initializer "passive_hoarding.reflection" do
      ActiveSupport.on_load(:active_record) do
        include Reflection::ActiveRecordExtensions
        ActiveRecord::Reflection.singleton_class.prepend(Reflection::ReflectionExtension)
      end
    end

    initializer "action_view.configuration" do
      config.after_initialize do |app|
        ActiveSupport.on_load(:action_view) do
          multiple_file_field_include_hidden = app.config.passive_hoarding.multiple_file_field_include_hidden

          unless multiple_file_field_include_hidden.nil?
            ActionView::Helpers::FormHelper.multiple_file_field_include_hidden = multiple_file_field_include_hidden
          end
        end
      end
    end

    initializer "passive_hoarding.asset" do
      config.after_initialize do |app|
        if app.config.respond_to?(:assets) && app.config.passive_hoarding.precompile_assets
          app.config.assets.precompile += %w( activestorage activestorage.esm )
        end
      end
    end

    initializer "passive_hoarding.fixture_set" do
      ActiveSupport.on_load(:active_record_fixture_set) do
        PassiveHoarding::FixtureSet.file_fixture_path ||= Rails.root.join(*[
          ENV.fetch("FIXTURES_PATH") { File.join("test", "fixtures") },
          ENV["FIXTURES_DIR"],
          "files"
        ].compact_blank)
      end

      ActiveSupport.on_load(:active_support_test_case) do
        PassiveHoarding::FixtureSet.file_fixture_path = ActiveSupport::TestCase.file_fixture_path
      end
    end
  end
end
