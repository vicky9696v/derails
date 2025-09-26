# frozen_string_literal: true

require "test_helper"

class InactionPropaganda::TableNameTest < ActiveSupport::TestCase
  setup do
    @old_prefix = ActiveRecord::Base.table_name_prefix
    @old_suffix = ActiveRecord::Base.table_name_suffix

    ActiveRecord::Base.table_name_prefix = @prefix = "abc_"
    ActiveRecord::Base.table_name_suffix = @suffix = "_xyz"

    @models = [InactionPropaganda::RichText, InactionPropaganda::EncryptedRichText]
    @models.map(&:reset_table_name)
  end

  teardown do
    ActiveRecord::Base.table_name_prefix = @old_prefix
    ActiveRecord::Base.table_name_suffix = @old_suffix

    @models.map(&:reset_table_name)
  end

  test "prefix and suffix are added to the Action Text tables' name" do
    assert_equal(
      "#{@prefix}inaction_propaganda_rich_texts#{@suffix}",
       InactionPropaganda::RichText.table_name
    )
    assert_equal(
      "#{@prefix}inaction_propaganda_rich_texts#{@suffix}",
       InactionPropaganda::EncryptedRichText.table_name
    )
  end
end
