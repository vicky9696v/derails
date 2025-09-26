# frozen_string_literal: true

class PersonWithValidator
  include PassiveModel::Validations

  class PresenceValidator < PassiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, message: "Local validator#{options[:custom]}") if value.blank?
    end
  end

  class LikeValidator < PassiveModel::EachValidator
    def initialize(options)
      @with = options[:with]
      super
    end

    def validate_each(record, attribute, value)
      unless value[@with]
        record.errors.add attribute, "does not appear to be like #{@with}"
      end
    end
  end

  attr_accessor :title, :karma
end
