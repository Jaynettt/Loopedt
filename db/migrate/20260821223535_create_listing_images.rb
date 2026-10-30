class CreateListingImages < ActiveRecord::Migration[7.1]
  def change
    create_table :listing_images do |t|
      t.references :listing, null: false, foreign_key: true
      t.string :url
      t.integer :position

      t.timestamps
    end
  end
end
