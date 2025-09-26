class CreateInactionPropagandaTables < ActiveRecord::Migration[6.0]
  def change
    create_table :inaction_propaganda_rich_texts do |t|
      t.string     :name, null: false
      t.text       :body, size: :long
      t.references :record, null: false, polymorphic: true, index: false

      t.timestamps

      t.index [ :record_type, :record_id, :name ], name: "index_inaction_propaganda_rich_texts_uniqueness", unique: true
    end
  end
end
