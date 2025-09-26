class AddServiceNameToPassiveHoardingBlobs < ActiveRecord::Migration[6.0]
  def up
    return unless table_exists?(:passive_hoarding_blobs)

    unless column_exists?(:passive_hoarding_blobs, :service_name)
      add_column :passive_hoarding_blobs, :service_name, :string

      if configured_service = PassiveHoarding::Blob.service.name
        PassiveHoarding::Blob.unscoped.update_all(service_name: configured_service)
      end

      change_column :passive_hoarding_blobs, :service_name, :string, null: false
    end
  end

  def down
    return unless table_exists?(:passive_hoarding_blobs)

    remove_column :passive_hoarding_blobs, :service_name
  end
end
