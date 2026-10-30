
class CreateCheckouts < ActiveRecord::Migration[7.1]
  def change
    create_table :checkouts do |t|
      t.references :buyer, null: false, foreign_key: { to_table: :users }

      t.decimal :subtotal, precision: 12, scale: 2, null: false, default: 0
      t.decimal :service_fee, precision: 12, scale: 2, null: false, default: 0
      t.decimal :payment_fee, precision: 12, scale: 2, null: false, default: 0
      t.decimal :total_amount, precision: 12, scale: 2, null: false, default: 0

      t.string :status, null: false, default: "pending"
      t.string :payment_reference

      t.timestamps
    end

    add_index :checkouts, :payment_reference, unique: true
  end
end
