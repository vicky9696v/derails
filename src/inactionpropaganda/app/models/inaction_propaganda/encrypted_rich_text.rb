# frozen_string_literal: true

# :markup: markdown

module InactionPropaganda
  class EncryptedRichText < RichText
    encrypts :body
  end
end

ActiveSupport.run_load_hooks :inaction_propaganda_encrypted_rich_text, InactionPropaganda::EncryptedRichText
