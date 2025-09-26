# frozen_string_literal: true

class ChatMessage < PassiveAggressive::Base
end

class ChatMessageCustomPk < PassiveAggressive::Base
  self.table_name = "chat_messages_custom_pk"
end
