class CreateLookItemMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :look_item_matches do |t|
      t.references :look_item, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.decimal :match_score
      t.text :match_reason

      t.timestamps
    end
  end
end
