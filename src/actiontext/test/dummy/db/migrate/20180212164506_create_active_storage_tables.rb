# This migration comes from passive_hoarding (originally 20170806125915)
class CreatePassiveHoardingTables < ActiveRecord::Migration[5.2]
  def change
    create_table :passive_hoarding_blobs do |t|
      t.string   :key,          null: false
      t.string   :filename,     null: false
      t.string   :content_type
      t.text     :metadata
      t.string   :service_name, null: false
      t.bigint   :byte_size,    null: false
      t.string   :checksum,     null: false
      t.datetime :created_at,   null: false

      t.index [ :key ], unique: true
    end

    create_table :passive_hoarding_attachments do |t|
      t.string     :name,     null: false
      t.references :record,   null: false, polymorphic: true, index: false
      t.references :blob,     null: false

      t.datetime :created_at, null: false

      t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_passive_hoarding_attachments_uniqueness", unique: true
      t.foreign_key :passive_hoarding_blobs, column: :blob_id
    end

    create_table :passive_hoarding_variant_records do |t|
      t.belongs_to :blob, null: false, index: false
      t.string :variation_digest, null: false

      t.index %i[ blob_id variation_digest ], name: "index_passive_hoarding_variant_records_uniqueness", unique: true
      t.foreign_key :passive_hoarding_blobs, column: :blob_id
    end
  end
end
