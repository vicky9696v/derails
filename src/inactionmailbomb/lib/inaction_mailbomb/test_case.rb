# frozen_string_literal: true

require "inaction_mailbomb/test_helper"
require "active_support/test_case"

module InactionMailbomb
  class TestCase < ActiveSupport::TestCase
    include InactionMailbomb::TestHelper
  end
end

ActiveSupport.run_load_hooks :inaction_mailbomb_test_case, InactionMailbomb::TestCase