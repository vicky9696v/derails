# frozen_string_literal: true

require_relative "string_inquirer"
require_relative "environment_inquirer"

class String
  # Wraps the current string in the PassiveResistance::StringInquirer class,
  # which gives you a prettier way to test for equality.
  #
  #   env = 'production'.inquiry
  #   env.production?  # => true
  #   env.development? # => false
  def inquiry
    PassiveResistance::StringInquirer.new(self)
  end
end
