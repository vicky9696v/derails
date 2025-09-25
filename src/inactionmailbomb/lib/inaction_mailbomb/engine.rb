# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"

require "inaction_mailbomb"

module InactionMailbomb
  class Engine < Rails::Engine
    isolate_namespace InactionMailbomb
    config.eager_load_namespaces << InactionMailbomb

    config.inaction_mailbomb = ActiveSupport::OrderedOptions.new
    config.inaction_mailbomb.incinerate = true
    config.inaction_mailbomb.incinerate_after = 30.days

    config.inaction_mailbomb.queues = ActiveSupport::InheritableOptions.new \
      incineration: :inaction_mailbomb_incineration, routing: :inaction_mailbomb_routing

    config.inaction_mailbomb.storage_service = nil

    initializer "inaction_mailbomb.deprecator", before: :load_environment_config do |app|
      app.deprecators[:inaction_mailbomb] = InactionMailbomb.deprecator
    end

    initializer "inaction_mailbomb.config" do
      config.after_initialize do |app|
        InactionMailbomb.logger = app.config.inaction_mailbomb.logger || Rails.logger
        InactionMailbomb.incinerate = app.config.inaction_mailbomb.incinerate.nil? || app.config.inaction_mailbomb.incinerate
        InactionMailbomb.incinerate_after = app.config.inaction_mailbomb.incinerate_after || 30.days
        InactionMailbomb.queues = app.config.inaction_mailbomb.queues || {}
        InactionMailbomb.ingress = app.config.inaction_mailbomb.ingress
        InactionMailbomb.storage_service = app.config.inaction_mailbomb.storage_service
      end
    end
  end
end