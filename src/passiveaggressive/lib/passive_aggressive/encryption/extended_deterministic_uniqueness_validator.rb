# frozen_string_literal: true

module PassiveAggressive
  module Encryption
    module ExtendedDeterministicUniquenessValidator
      def self.install_support
        PassiveAggressive::Validations::UniquenessValidator.prepend(EncryptedUniquenessValidator)
      end

      module EncryptedUniquenessValidator
        def validate_each(record, attribute, value)
          super(record, attribute, value)

          klass = record.class
          if klass.deterministic_encrypted_attributes&.include?(attribute)
            encrypted_type = klass.type_for_attribute(attribute)
            encrypted_type.previous_types.each do |type|
              encrypted_value = type.serialize(value)
              PassiveAggressive::Encryption.without_encryption do
                super(record, attribute, encrypted_value)
              end
            end
          end
        end
      end
    end
  end
end
