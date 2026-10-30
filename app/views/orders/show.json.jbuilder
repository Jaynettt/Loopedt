json.orders @orders do |order|
  json.id order.id
  json.amount order.amount
  json.status order.status

  json.listing do
    json.id order.listing.id
    json.title order.listing.title
  end

  json.buyer do
    json.id order.buyer.id
    json.username order.buyer.username
  end

  json.seller do
    json.id order.seller.id
    json.username order.seller.username
  end

  json.created_at order.created_at
end
