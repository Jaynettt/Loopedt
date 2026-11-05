json.category do
  json.id @category.id
  json.name @category.name

  json.listings @listings do |listing|
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

    json.seller do
      json.id listing.user.id
      json.username listing.user.username
    end
  end
end
