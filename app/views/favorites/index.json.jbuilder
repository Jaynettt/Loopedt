json.favorites @favorites do |favorite|
  listing = favorite.listing

  json.id favorite.id

  json.listing do
    json.id listing.id
    json.title listing.title
    json.price listing.price
    json.condition listing.condition
    json.brand listing.brand
    json.size listing.size
    json.colour listing.colour

    json.images listing.images do |image|
      json.id image.id
      json.url url_for(image) if image.attached?
    end
  end
end
