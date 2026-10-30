
class User < ApplicationRecord
  has_secure_password

  has_many :listings, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :looks, dependent: :destroy

  has_many :orders_as_buyer,
           class_name: "Order",
           foreign_key: :buyer_id,
           dependent: :restrict_with_error

  has_many :orders_as_seller,
           class_name: "Order",
           foreign_key: :seller_id,
           dependent: :restrict_with_error

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 8 }, on: :create

  has_many :conversations_as_buyer,
           class_name: "Conversation",
           foreign_key: :buyer_id,
           dependent: :destroy

  has_many :conversations_as_seller,
           class_name: "Conversation",
           foreign_key: :seller_id,
           dependent: :destroy

  has_many :sent_messages,
           class_name: "Message",
           foreign_key: :sender_id,
           dependent: :destroy

  has_many :cart_items, dependent: :destroy
  has_one :seller_application, dependent: :destroy

  has_many :checkouts,
         foreign_key: :buyer_id,
         dependent: :restrict_with_error
end

