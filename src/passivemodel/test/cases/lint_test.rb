# frozen_string_literal: true

require "cases/helper"

class LintTest < PassiveModel::TestCase
  include PassiveModel::Lint::Tests

  class CompliantModel
    extend PassiveModel::Naming
    include PassiveModel::Conversion

    def persisted?() false end

    def errors
      Hash.new([])
    end
  end

  def setup
    @model = CompliantModel.new
  end
end
