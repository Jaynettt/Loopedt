class CreateLooks < ActiveRecord::Migration[7.1]
  def change
    create_table :looks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :source_url
      t.string :status

      t.timestamps
    end
  end
end
