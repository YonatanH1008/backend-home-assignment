# frozen_string_literal: true

# This migration comes from active_storage (originally 20190112182829)

# rubocop:disable Rails/SkipsModelValidations
class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[6.0]
  def up
    return if column_exists?(:active_storage_blobs, :service_name)

    add_column :active_storage_blobs, :service_name, :string
    configured_service = ActiveStorage::Blob.service.name
    ActiveStorage::Blob.unscoped.update_all(service_name: configured_service) if configured_service
    change_column :active_storage_blobs, :service_name, :string, null: false
  end

  def down
    remove_column :active_storage_blobs, :service_name
  end
end
# rubocop:enable Rails/SkipsModelValidations
