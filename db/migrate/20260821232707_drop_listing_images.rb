class DropListingImages < ActiveRecord::Migration[7.1]
  def change
    drop_table :listing_images
  end
end
