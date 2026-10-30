json.categories @categories do |category|
  json.id category.id
  json.name category.name
  json.listing_count category.listings.count
end
