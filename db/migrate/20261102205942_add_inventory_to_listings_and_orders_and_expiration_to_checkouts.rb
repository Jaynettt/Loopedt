class AddInventoryToListingsAndOrdersAndExpirationToCheckouts < ActiveRecord::Migration[7.1]
  def up
    add_column :listings, :stock_quantity, :integer,
               default: 1, null: false

    add_column :listings, :reserved_quantity, :integer,
               default: 0, null: false

    add_column :orders, :quantity, :integer,
               default: 1, null: false

    add_column :checkouts, :expires_at, :datetime

    add_check_constraint :listings,
                         "stock_quantity >= 0",
                         name: "listings_stock_quantity_nonnegative"

    add_check_constraint :listings,
                         "reserved_quantity >= 0 AND reserved_quantity <= stock_quantity",
                         name: "listings_reserved_quantity_valid"

    add_check_constraint :orders,
                         "quantity > 0",
                         name: "orders_quantity_positive"
  end

  def down
    remove_check_constraint :orders,
                            name: "orders_quantity_positive"

    remove_check_constraint :listings,
                            name: "listings_reserved_quantity_valid"

    remove_check_constraint :listings,
                            name: "listings_stock_quantity_nonnegative"

    remove_column :checkouts, :expires_at
    remove_column :orders, :quantity
    remove_column :listings, :reserved_quantity
    remove_column :listings, :stock_quantity
  end
end
