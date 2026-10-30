
# db/seeds.rb

require "open-uri"
require "stringio"
require "securerandom"

puts "🌱 Seeding Loopedt database..."

# =========================
# CLEAR EXISTING DATA
# =========================

# =========================
# CLEAR EXISTING DATA
# =========================

puts "Clearing existing records..."

# Delete messages before conversations
# Message.destroy_all if defined?(Message)

# Delete conversations before listings
# Conversation.destroy_all if defined?(Conversation)

# Delete orders and favourites
Order.destroy_all
Favorite.destroy_all

# Delete cart items if the model exists
CartItem.destroy_all if defined?(CartItem)

# Delete listings and their images
# Listing.destroy_all

# Delete categories and users
# Category.destroy_all
# User.destroy_all

puts "Existing records cleared."
# =========================
# USERS
# =========================

users = User.create!([
  {
    email: "janet@example.com",
    password: "password123",
    username: "janet",
    first_name: "Janet",
    last_name: "Uche",
    phone_number: "08012345678",
    bio: "Fashion lover and vintage collector.",
    verified: true
  },
  {
    email: "john@example.com",
    password: "password123",
    username: "john",
    first_name: "John",
    last_name: "Doe",
    phone_number: "08023456789",
    bio: "I love buying and selling sneakers.",
    verified: true
  },
  {
    email: "mary@example.com",
    password: "password123",
    username: "mary",
    first_name: "Mary",
    last_name: "Smith",
    phone_number: "08034567890",
    bio: "Vintage fashion enthusiast.",
    verified: false
  }
])

janet, john, mary = users

# =========================
# CATEGORIES
# =========================

clothing = Category.create!(name: "Clothing")
shoes = Category.create!(name: "Shoes")
electronics = Category.create!(name: "Electronics")
accessories = Category.create!(name: "Accessories")

categories = [clothing, shoes, electronics, accessories]

# =========================
# PRODUCT-SPECIFIC IMAGE URLS
# CLOTHING, SHOES AND ACCESSORIES ONLY
# =========================

product_image_urls = {
  /jacket|coat|trench/i => [
    "https://images.unsplash.com/photo-1551028719-00167b16eac5?fit=crop&w=900&q=80&fm=jpg",
    "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?fit=crop&w=900&q=80&fm=jpg"
  ],

  /dress|skirt|blouse|top|shirt|jumpsuit/i => [
    "https://images.unsplash.com/photo-1483985988355-763728e1935b?fit=crop&w=900&q=80&fm=jpg"
  ],

  /jeans|trousers|pants|track pants/i => [
    "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?fit=crop&w=900&q=80&fm=jpg"
  ],

  /sneaker|trainer|running shoes|basketball/i => [
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff?fit=crop&w=900&q=80&fm=jpg",
    "https://images.unsplash.com/photo-1549298916-b41d501d3772?fit=crop&w=900&q=80&fm=jpg"
  ],

  /heels|sandals|flats|mules|slides/i => [
    "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?fit=crop&w=900&q=80&fm=jpg"
  ],

  /boots|loafers|oxford/i => [
    "https://images.unsplash.com/photo-1549298916-b41d501d3772?fit=crop&w=900&q=80&fm=jpg"
  ],

  /handbag|shoulder bag|crossbody|clutch/i => [
    "https://images.unsplash.com/photo-1584917865442-de89df76afd3?fit=crop&w=900&q=80&fm=jpg"
  ],

  /backpack|tote|weekender/i => [
    "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?fit=crop&w=900&q=80&fm=jpg"
  ],

  /sunglasses/i => [
    "https://images.unsplash.com/photo-1511499767150-a48a237f0083?fit=crop&w=900&q=80&fm=jpg"
  ],

  /wallet|belt|necklace|bracelet|earrings|ring|scarf|hat|cap/i => [
    "https://images.unsplash.com/photo-1584917865442-de89df76afd3?fit=crop&w=900&q=80&fm=jpg"
  ]
}

# =========================
# DOWNLOAD PRODUCT IMAGES
# =========================

puts "Downloading clothing, shoe and accessory images..."

image_cache = {}

product_image_urls.values.flatten.uniq.each do |url|
  begin
    URI.open(
      url,
      open_timeout: 10,
      read_timeout: 20,
      "User-Agent" => "LoopedtSeed/1.0"
    ) do |file|

      content_type = file.content_type

      unless content_type&.start_with?("image/")
        raise "URL did not return an image"
      end

      image_cache[url] = {
        data: file.read,
        content_type: content_type
      }
    end

    puts "Downloaded: #{url}"

  rescue StandardError => e
    warn "Image download failed: #{url}"
    warn e.message
  end
end

# =========================
# IMAGE ATTACHMENT HELPER
# =========================

attach_seed_image = lambda do |listing, category|

  # Electronics do not receive product-specific images.
  next if category == electronics

  matching_rule = product_image_urls.find do |pattern, _urls|
    listing.title.match?(pattern)
  end

  urls = matching_rule ? matching_rule.last : []

  available_urls = urls.select do |url|
    image_cache.key?(url)
  end

  if available_urls.empty?
    warn "No matching image available for: #{listing.title}"
    next
  end

  url = available_urls.sample
  cached_image = image_cache.fetch(url)

  extension = case cached_image[:content_type]
              when "image/png" then ".png"
              when "image/webp" then ".webp"
              else ".jpg"
              end

  listing.images.attach(
    io: StringIO.new(cached_image[:data]),
    filename: "loopedt-#{SecureRandom.hex(8)}#{extension}",
    content_type: cached_image[:content_type]
  )
end

# =========================
# ORIGINAL LISTINGS
# =========================

listing1 = Listing.create!(
  user: janet,
  category: clothing,
  title: "Vintage Denim Jacket",
  description: "Classic blue vintage denim jacket in excellent condition.",
  price: 25000,
  condition: "Like New",
  brand: "Levi's",
  size: "M",
  colour: "Blue",
  status: "available"
)

attach_seed_image.call(listing1, clothing)

listing2 = Listing.create!(
  user: john,
  category: shoes,
  title: "Nike Air Force 1",
  description: "Clean white Nike Air Force 1 sneakers.",
  price: 65000,
  condition: "Good",
  brand: "Nike",
  size: "42",
  colour: "White",
  status: "available"
)

attach_seed_image.call(listing2, shoes)

listing3 = Listing.create!(
  user: mary,
  category: accessories,
  title: "Leather Handbag",
  description: "Brown leather handbag, lightly used.",
  price: 40000,
  condition: "Good",
  brand: "Michael Kors",
  size: "Medium",
  colour: "Brown",
  status: "available"
)

attach_seed_image.call(listing3, accessories)

listing4 = Listing.create!(
  user: janet,
  category: electronics,
  title: "Wireless Headphones",
  description: "Wireless headphones with noise cancellation.",
  price: 85000,
  condition: "Like New",
  brand: "Sony",
  size: nil,
  colour: "Black",
  status: "available"
)

# Electronics intentionally have no seed image attached.

# =========================
# PRODUCT COLLECTIONS
# =========================

listing_products = {
  clothing => [
    "Denim Jacket", "Graphic T-Shirt", "Linen Shirt",
    "Floral Dress", "Wide Leg Jeans", "Leather Jacket",
    "Maxi Skirt", "Blazer", "Knit Sweater", "Cargo Trousers",
    "Vintage Hoodie", "Silk Blouse", "Summer Dress",
    "Cardigan", "Track Pants", "Polo Shirt",
    "Tailored Trousers", "Jumpsuit", "Crop Top", "Trench Coat"
  ],

  shoes => [
    "Running Sneakers", "Leather Loafers", "Canvas Trainers",
    "Ankle Boots", "High Top Sneakers", "Ballet Flats",
    "Block Heel Sandals", "Slides", "Chelsea Boots",
    "Basketball Sneakers", "Platform Shoes", "Oxford Shoes",
    "Slip On Sneakers", "Kitten Heels", "Walking Shoes",
    "Strappy Sandals", "Hiking Boots", "Mules",
    "Court Sneakers", "Dress Shoes"
  ],

  electronics => [
    "Wireless Headphones", "Bluetooth Speaker", "Smartwatch",
    "Mechanical Keyboard", "Wireless Mouse", "Digital Camera",
    "Tablet", "Laptop Stand", "Power Bank", "Gaming Controller",
    "USB Microphone", "Ring Light", "Portable Monitor",
    "Webcam", "External SSD", "E-Reader", "Desk Lamp",
    "Phone Charger", "Wireless Earbuds", "Gaming Headset"
  ],

  accessories => [
    "Leather Handbag", "Crossbody Bag", "Gold Tone Necklace",
    "Classic Wristwatch", "Leather Wallet", "Sunglasses",
    "Canvas Tote Bag", "Beaded Bracelet", "Shoulder Bag",
    "Minimalist Earrings", "Travel Backpack", "Silk Scarf",
    "Bucket Hat", "Leather Belt", "Pendant Necklace",
    "Clutch Bag", "Baseball Cap", "Card Holder",
    "Statement Ring", "Weekender Bag"
  ]
}

# =========================
# LISTING DESCRIPTORS
# =========================

descriptors = [
  "Vintage", "Classic", "Modern", "Minimalist", "Premium",
  "Everyday", "Retro", "Designer", "Casual", "Elegant",
  "Contemporary", "Timeless", "Streetwear", "Essential",
  "Trendy", "Original", "Stylish", "Limited Edition",
  "Pre-loved", "Signature", "Urban", "Luxury", "Relaxed",
  "Sporty", "Chic"
]

brands = {
  clothing => [
    "Zara", "H&M", "Levi's", "Uniqlo", "Mango",
    "Nike", "Adidas", "ASOS", "Pull&Bear", "Vintage"
  ],

  shoes => [
    "Nike", "Adidas", "Puma", "Converse", "Vans",
    "New Balance", "Clarks", "Reebok", "ASOS", "Dr. Martens"
  ],

  electronics => [
    "Sony", "Samsung", "Apple", "JBL", "Anker",
    "Logitech", "HP", "Dell", "Lenovo", "Xiaomi"
  ],

  accessories => [
    "Michael Kors", "Coach", "Guess", "Zara", "Fossil",
    "Charles & Keith", "Aldo", "Calvin Klein",
    "Accessorize", "Vintage"
  ]
}

colours = [
  "Black", "White", "Blue", "Brown", "Beige", "Grey",
  "Green", "Red", "Pink", "Cream", "Navy", "Multicolour"
]

conditions = ["Like New", "Good", "Fair", "New"]

clothing_sizes = ["XS", "S", "M", "L", "XL", "XXL"]
shoe_sizes = ["36", "37", "38", "39", "40", "41", "42", "43", "44", "45"]
accessory_sizes = ["Small", "Medium", "Large", nil]

# =========================
# CREATE 500 ADDITIONAL LISTINGS
# =========================

puts "Creating 500 additional listings..."

500.times do |i|
  category = categories[i % categories.length]

  product_list = listing_products.fetch(category)
  product = product_list[(i / categories.length) % product_list.length]

  descriptor = descriptors.sample
  condition = conditions.sample
  colour = colours.sample
  brand = brands.fetch(category).sample

  size = case category
         when clothing
           clothing_sizes.sample
         when shoes
           shoe_sizes.sample
         when accessories
           accessory_sizes.sample
         else
           nil
         end

  price = case category
          when clothing
            rand(5_000..45_000)
          when shoes
            rand(10_000..120_000)
          when electronics
            rand(8_000..350_000)
          when accessories
            rand(3_000..100_000)
          end

  listing = Listing.create!(
    user: users.sample,
    category: category,
    title: "#{descriptor} #{product} ##{i + 1}",
    description: "#{descriptor} #{product.downcase} in #{condition.downcase} condition. A great pre-loved find for your collection.",
    price: price,
    condition: condition,
    brand: brand,
    size: size,
    colour: colour,
    status: "available"
  )

  attach_seed_image.call(listing, category)

  puts "Created listing #{i + 1}/500" if (i + 1) % 50 == 0
end

# =========================
# FAVORITES
# =========================

Favorite.create!(
  user: john,
  listing: listing1
)

Favorite.create!(
  user: mary,
  listing: listing2
)

Favorite.create!(
  user: janet,
  listing: listing3
)

# =========================
# ORDERS
# =========================

Order.create!(
  listing: listing1,
  buyer: john,
  seller: janet,
  amount: listing1.price,
  status: "completed"
)

Order.create!(
  listing: listing2,
  buyer: mary,
  seller: john,
  amount: listing2.price,
  status: "pending"
)

# =========================
# SUMMARY
# =========================

puts "=================================="
puts "✅ Loopedt seeding complete!"
puts "Users: #{User.count}"
puts "Categories: #{Category.count}"
puts "Listings: #{Listing.count}"
puts "Favorites: #{Favorite.count}"
puts "Orders: #{Order.count}"

puts "Listings with images: #{Listing.joins(images_attachments: :blob).distinct.count}"

puts "Listings without images: #{Listing.left_joins(:images_attachments).where(active_storage_attachments: { id: nil }).count}"

puts "=================================="
