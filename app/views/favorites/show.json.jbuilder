json.favorite do
  json.id @favorite.id
  json.listing_id @favorite.listing_id
  json.user_id @favorite.user_id
end
