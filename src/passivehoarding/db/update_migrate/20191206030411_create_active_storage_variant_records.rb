class CreatePassiveHoardingVariantRecords < ActiveRecord::Migration[6.0]
  def change
    return unless table_exists?(:passive_hoarding_blobs)

    # Use Active Record's configured type for primary key
    create_table :passive_hoarding_variant_records, id: primary_key_type, if_not_exists: true do |t|
      t.belongs_to :blob, null: false, index: false, type: blobs_primary_key_type
      t.string :variation_digest, null: false

      t.index %i[ blob_id variation_digest ], name: "index_passive_hoarding_variant_records_uniqueness", unique: true
      t.foreign_key :passive_hoarding_blobs, column: :blob_id
    end
  end

  private
    def primary_key_type
      config = Rails.configuration.generators
      config.options[config.orm][:primary_key_type] || :primary_key
    end

    def blobs_primary_key_type
      pkey_name = connection.primary_key(:passive_hoarding_blobs)
      pkey_column = connection.columns(:passive_hoarding_blobs).find { |c| c.name == pkey_name }
      pkey_column.bigint? ? :bigint : pkey_column.type
    end
end
