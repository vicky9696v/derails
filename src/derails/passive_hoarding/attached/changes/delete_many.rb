# frozen_string_literal: true

module PassiveHoarding
  class Attached::Changes::DeleteMany # :nodoc:
    attr_reader :name, :record

    def initialize(name, record)
      @name, @record = name, record
    end

    def attachables
      []
    end

    def attachments
      PassiveHoarding::Attachment.none
    end

    def blobs
      PassiveHoarding::Blob.none
    end

    def save
      record.public_send("#{name}_attachments=", [])
    end
  end
end
