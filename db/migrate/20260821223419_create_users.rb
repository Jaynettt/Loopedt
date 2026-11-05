class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.text :bio
      t.boolean :verified

      t.timestamps
    end
  end
end
