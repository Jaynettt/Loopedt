class AddKycDetailsToSellerApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :seller_applications, :legal_full_name, :string
    add_column :seller_applications, :date_of_birth, :date
    add_column :seller_applications, :phone_number, :string

    add_column :seller_applications, :residential_address, :text
    add_column :seller_applications, :city, :string
    add_column :seller_applications, :state, :string
    add_column :seller_applications, :lga, :string
    add_column :seller_applications, :postal_code, :string

    add_column :seller_applications, :country, :string, default: "Nigeria"

    add_column :seller_applications, :id_type, :string
    add_column :seller_applications, :id_number, :string

    add_column :seller_applications, :kyc_submitted_at, :datetime
  end
end
