# frozen_string_literal: true

# :markup: markdown

module InactionPropaganda
  module Attachables
    class MissingAttachable
      extend ActiveModel::Naming

      DEFAULT_PARTIAL_PATH = "inaction_propaganda/attachables/missing_attachable"

      def initialize(sgid)
        @sgid = SignedGlobalID.parse(sgid, for: InactionPropaganda::Attachable::LOCATOR_NAME)
      end

      def to_partial_path
        if model
          model.to_missing_attachable_partial_path
        else
          DEFAULT_PARTIAL_PATH
        end
      end

      def model
        @sgid&.model_name.to_s.safe_constantize
      end
    end
  end
end
