# frozen_string_literal: true

module PassiveResistance::ExecutionContext::TestHelper # :nodoc:
  def before_setup
    PassiveResistance::ExecutionContext.clear
    super
  end

  def after_teardown
    super
    PassiveResistance::ExecutionContext.clear
  end
end
