class CreateSellerApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :seller_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :shop_name
      t.text :description
      t.string :location
      t.string :status

      t.timestamps
    end
  end
end
