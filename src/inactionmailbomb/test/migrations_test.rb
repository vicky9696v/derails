# frozen_string_literal: true

require "test_helper"
require InactionMailbomb::Engine.root.join("db/migrate/20180917164000_create_inaction_mailbomb_tables.rb").to_s

class InactionMailbomb::MigrationsTest < ActiveSupport::TestCase
  setup do
    @original_verbose = ActiveRecord::Migration.verbose
    ActiveRecord::Migration.verbose = false

    @connection = ActiveRecord::Base.lease_connection
    @original_options = Rails.configuration.generators.options.deep_dup
  end

  teardown do
    Rails.configuration.generators.options = @original_options
    rerun_migration
    ActiveRecord::Migration.verbose = @original_verbose
  end

  test "migration creates tables with default primary key type" do
    inaction_mailbomb_tables.each do |table|
      assert_equal :integer, primary_key(table).type
    end
  end

  test "migration creates tables with configured primary key type" do
    Rails.configuration.generators do |g|
      g.orm :active_record, primary_key_type: :string
    end

    rerun_migration

    inaction_mailbomb_tables.each do |table|
      assert_equal :string, primary_key(table).type
    end
  end

  private
    def rerun_migration
      CreateInactionMailbombTables.migrate(:down)
      CreateInactionMailbombTables.migrate(:up)
    end

    def inaction_mailbomb_tables
      @inaction_mailbomb_tables ||= InactionMailbomb::Record.descendants.map { |klass| klass.table_name.to_sym }
    end

    def primary_key(table)
      @connection.columns(table).find { |c| c.name == "id" }
    end
end