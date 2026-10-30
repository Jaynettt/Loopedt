
class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true

      t.references :sender,
                   null: false,
                   foreign_key: { to_table: :users }

      t.text :body, null: false
      t.string :moderation_status, null: false, default: "pending"

      t.timestamps
    end
  end
end
