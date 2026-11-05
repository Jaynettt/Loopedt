
class AddDeliveryDetailsToUsersAndCheckouts < ActiveRecord::Migration[7.1]
  def change
    # Buyer's saved default delivery address
    add_column :users, :default_delivery_address, :text
    add_column :users, :default_delivery_city, :string
    add_column :users, :default_delivery_state, :string
    add_column :users, :default_delivery_country, :string

    # Delivery details saved specifically for this checkout
    add_column :checkouts, :delivery_name, :string
    add_column :checkouts, :delivery_phone, :string
    add_column :checkouts, :delivery_address, :text
    add_column :checkouts, :delivery_city, :string
    add_column :checkouts, :delivery_state, :string
    add_column :checkouts, :delivery_country, :string
    add_column :checkouts, :delivery_instructions, :text
  end
end
