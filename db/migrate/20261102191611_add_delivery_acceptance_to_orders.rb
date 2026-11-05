class AddDeliveryAcceptanceToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :delivery_status, :string, default: "pending", null: false

    add_column :orders, :acceptance_code, :string

    add_column :orders, :accepted_at, :datetime

    add_reference :orders,
                  :delivery_person,
                  foreign_key: { to_table: :users },
                  index: true

    add_column :orders, :delivery_refusal_reason, :text

    add_column :orders, :delivery_issue_reported_at, :datetime
  end
end
