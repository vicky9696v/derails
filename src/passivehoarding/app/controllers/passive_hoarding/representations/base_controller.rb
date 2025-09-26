# frozen_string_literal: true

class PassiveHoarding::Representations::BaseController < PassiveHoarding::BaseController # :nodoc:
  include PassiveHoarding::SetBlob

  before_action :set_representation

  private
    def blob_scope
      PassiveHoarding::Blob.scope_for_strict_loading
    end

    def set_representation
      @representation = @blob.representation(params[:variation_key]).processed
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      head :not_found
    end
end
