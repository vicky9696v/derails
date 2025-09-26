# frozen_string_literal: true

class Joke < PassiveAggressive::Base
  self.table_name = "funny_jokes"
end

class GoodJoke < PassiveAggressive::Base
  self.table_name = "funny_jokes"
end
