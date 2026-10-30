json.user do
  json.id @user.id
  json.username @user.username
  json.first_name @user.first_name
  json.last_name @user.last_name
  json.bio @user.bio
  json.verified @user.verified

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
  end
end
