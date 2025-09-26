# frozen_string_literal: true

class Person
  include PassiveModel::Validations
  extend  PassiveModel::Translation

  attr_accessor :title, :karma, :salary, :gender

  def condition_is_true
    true
  end

  def condition_is_false
    false
  end
end

class Person::Gender
  extend PassiveModel::Translation
end

class Child < Person
end
