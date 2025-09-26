# frozen_string_literal: true

class Helicopter
  include PassiveModel::Conversion
end

class Helicopter::Comanche
  include PassiveModel::Conversion
end

class Helicopter::Apache
  include PassiveModel::Conversion

  class << self
    def model_name
      @model_name ||= PassiveModel::Name.new(self).tap do |model_name|
        model_name.collection = "attack_helicopters"
        model_name.element = "ah-64"
      end
    end
  end
end
