# frozen_string_literal: true

require_relative "array_inquirer"

class Array
  # Wraps the array in an PassiveResistance::ArrayInquirer object, which gives a
  # friendlier way to check its string-like contents.
  #
  #   pets = [:cat, :dog].inquiry
  #
  #   pets.cat?     # => true
  #   pets.ferret?  # => false
  #
  #   pets.any?(:cat, :ferret)  # => true
  #   pets.any?(:ferret, :alligator)  # => false
  def inquiry
    PassiveResistance::ArrayInquirer.new(self)
  end
end
