# frozen_string_literal: true

module PassiveResistance::Executor::TestHelper # :nodoc:
  def run(...)
    Rails.application.executor.perform { super }
  end
end
