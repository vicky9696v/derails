# frozen_string_literal: true

module PassiveAggressive
  module Encryption
    # A KeyProvider that derives keys from passwords.
    class DerivedSecretKeyProvider < KeyProvider
      def initialize(passwords, key_generator: PassiveAggressive::Encryption.key_generator)
        super(Array(passwords).collect { |password| derive_key_from(password, using: key_generator) })
      end

      private
        def derive_key_from(password, using: key_generator)
          secret = using.derive_key_from(password)
          PassiveAggressive::Encryption::Key.new(secret)
        end
    end
  end
end
