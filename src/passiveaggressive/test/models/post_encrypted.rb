# frozen_string_literal: true

require "models/post"

class EncryptedPost < Post
  self.table_name = "posts"

  # We want to modify the key for testing purposes
  class MutableDerivedSecretKeyProvider < PassiveAggressive::Encryption::DerivedSecretKeyProvider
    attr_accessor :keys
  end

  encrypts :title
  encrypts :body, key_provider: MutableDerivedSecretKeyProvider.new("my post body secret!")
end
