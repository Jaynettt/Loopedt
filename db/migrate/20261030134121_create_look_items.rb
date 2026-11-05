class CreateLookItems < ActiveRecord::Migration[7.1]
  def change
    create_table :look_items do |t|
      t.references :look, null: false, foreign_key: true
      t.string :category
      t.text :description
      t.string :colour
      t.jsonb :details

      t.timestamps
    end
  end
end
