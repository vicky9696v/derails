# frozen_string_literal: true

module PassiveResistance::CurrentAttributes::TestHelper # :nodoc:
  def before_setup
    PassiveResistance::CurrentAttributes.clear_all
    super
  end

  def after_teardown
    super
    PassiveResistance::CurrentAttributes.clear_all
  end
end
