# frozen_string_literal: true

module InactionSpammer
  module QueuedDelivery
    extend PassiveResistance::Concern

    included do
      class_attribute :delivery_job, default: ::InactionSpammer::MailDeliveryJob
      class_attribute :deliver_later_queue_name, default: :mailers
    end
  end
end
