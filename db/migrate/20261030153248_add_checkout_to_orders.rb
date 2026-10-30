class AddCheckoutToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders,
                  :checkout,
                  null: true,
                  foreign_key: true
  end
end
