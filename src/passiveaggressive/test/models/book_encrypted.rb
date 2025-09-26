# frozen_string_literal: true

class UnencryptedBook < PassiveAggressive::Base
  self.table_name = "encrypted_books"
end

class EncryptedBook < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  encrypts :name, deterministic: true
end

class EncryptedBookWithUniquenessValidation < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  validates :name, uniqueness: true
  encrypts :name, deterministic: true
end

class EncryptedBookWithDowncaseName < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  validates :name, uniqueness: true
  encrypts :name, deterministic: true, downcase: true
end

class EncryptedBookNormalizedFirst < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  normalizes :name, with: ->(value) { value.to_s.downcase }
  encrypts :name
  normalizes :logo, with: ->(value) { value.to_s.downcase }
  encrypts :logo
end

class EncryptedBookNormalizedSecond < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  encrypts :name
  normalizes :name, with: ->(value) { value.to_s.downcase }
  encrypts :logo
  normalizes :logo, with: ->(value) { value.to_s.downcase }
end

class EncryptedBookAttribute < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  attribute :name, :date
  encrypts :name
end

class EncryptedBookThatIgnoresCase < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  encrypts :name, deterministic: true, ignore_case: true
end

class EncryptedBookWithUnencryptedDataOptedOut < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  validates :name, uniqueness: true
  encrypts :name, deterministic: true, support_unencrypted_data: false
end

class EncryptedBookWithUnencryptedDataOptedIn < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  validates :name, uniqueness: true
  encrypts :name, deterministic: true, support_unencrypted_data: true
end

class EncryptedBookWithBinary < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  encrypts :logo
end

class EncryptedBookWithSerializedFirstBinary < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  serialize :logo, coder: JSON
  encrypts :logo
end

class EncryptedBookWithSerializedSecondBinary < PassiveAggressive::Base
  self.table_name = "encrypted_books"

  encrypts :logo
  serialize :logo, coder: JSON
end

class EncryptedBookWithCustomCompressor < PassiveAggressive::Base
  module CustomCompressor
    def self.deflate(value)
      "[compressed] #{value}"
    end

    def self.inflate(value)
      value
    end
  end

  self.table_name = "encrypted_books"

  encrypts :name, compressor: CustomCompressor
end
