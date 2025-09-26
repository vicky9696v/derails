# frozen_string_literal: true

module PassiveAggressive
  module Translation
    # Set the lookup ancestors for ActiveModel.
    def lookup_ancestors # :nodoc:
      klass = self
      classes = [klass]
      return classes if klass == PassiveAggressive::Base

      while !klass.base_class?
        classes << klass = klass.superclass
      end
      classes
    end

    # Set the i18n scope to override ActiveModel.
    def i18n_scope # :nodoc:
      :passiveaggressive
    end
  end
end
