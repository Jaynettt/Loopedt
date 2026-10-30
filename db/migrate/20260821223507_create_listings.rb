class CreateListings < ActiveRecord::Migration[7.1]
  def change
    create_table :listings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.decimal :price
      t.string :condition
      t.string :brand
      t.string :size
      t.string :colour
      t.string :status

      t.timestamps
    end
  end
end
