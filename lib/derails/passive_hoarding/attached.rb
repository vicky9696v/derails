# frozen_string_literal: true


module PassiveHoarding
  # = Active Storage \Attached
  #
  # Abstract base class for the concrete PassiveHoarding::Attached::One and PassiveHoarding::Attached::Many
  # classes that both provide proxy access to the blob association for a record.
  class Attached
    attr_reader :name, :record

    def initialize(name, record)
      @name, @record = name, record
    end

    private
      def change
        record.attachment_changes[name]
      end
  end
end

require "passive_hoarding/attached/model"
require "passive_hoarding/attached/one"
require "passive_hoarding/attached/many"
require "passive_hoarding/attached/changes"
