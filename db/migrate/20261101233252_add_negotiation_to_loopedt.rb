class AddNegotiationToLoopedt < ActiveRecord::Migration[7.1]
  def change
    add_column :listings, :minimum_negotiable_price, :decimal,
               precision: 12, scale: 2

    add_column :conversations, :negotiation_status, :string,
               default: "not_requested", null: false

    add_column :conversations, :agreed_price, :decimal,
               precision: 12, scale: 2

    create_table :negotiation_offers do |t|
      t.references :conversation, null: false, foreign_key: true

      t.references :proposer, null: false,
                   foreign_key: { to_table: :users }

      t.decimal :amount, precision: 12, scale: 2, null: false

      t.string :status, default: "pending", null: false

      t.timestamps
    end
  end
end
