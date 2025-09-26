class RemoveNotNullOnPassiveHoardingBlobsChecksum < ActiveRecord::Migration[6.0]
  def change
    return unless table_exists?(:passive_hoarding_blobs)

    change_column_null(:passive_hoarding_blobs, :checksum, true)
  end
end
