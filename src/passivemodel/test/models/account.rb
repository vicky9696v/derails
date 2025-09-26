# frozen_string_literal: true

class Account
  include PassiveModel::ForbiddenAttributesProtection

  public :sanitize_for_mass_assignment
end
