json.listings @listings do |listing|
  json.id listing.id
  json.title listing.title
  json.description listing.description
  json.price listing.price
  json.condition listing.condition
  json.brand listing.brand
  json.size listing.size
  json.colour listing.colour
  json.status listing.status

  json.measurements do
    json.bust listing.bust
    json.waist listing.waist
    json.hips listing.hips
    json.length listing.length
  end

  json.category do
    json.id listing.category.id
    json.name listing.category.name
  end

  json.seller do
    json.id listing.user.id
    json.username listing.user.username
    json.first_name listing.user.first_name
    json.last_name listing.user.last_name
    json.bio listing.user.bio
  end

  json.images listing.images do |image|
    json.id image.id

    if image.attached?
      json.url url_for(image)
    end
  end

  json.created_at listing.created_at
end
