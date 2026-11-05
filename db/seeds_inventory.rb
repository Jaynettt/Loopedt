# db/seeds_inventory.rb

puts "Starting Loopedt inventory seeding..."

# ==========================================
# 1. CREATE TEST SELLERS
# ==========================================

seller_records = [
  {
    email: "seller.alex@loopedt.test",
    password: "password123",
    username: "alex_sells",
    first_name: "Alex",
    last_name: "Morgan",
    phone_number: "08040000001",
    bio: "Curated pre-loved fashion and everyday finds.",
    verified: true
  },
  {
    email: "seller.sarah@loopedt.test",
    password: "password123",
    username: "sarah_style",
    first_name: "Sarah",
    last_name: "Williams",
    phone_number: "08040000002",
    bio: "Fashion seller offering quality clothing.",
    verified: true
  },
  {
    email: "seller.daniel@loopedt.test",
    password: "password123",
    username: "daniel_kicks",
    first_name: "Daniel",
    last_name: "Okafor",
    phone_number: "08040000003",
    bio: "Sneakers, shoes and streetwear.",
    verified: true
  },
  {
    email: "seller.amina@loopedt.test",
    password: "password123",
    username: "amina_collective",
    first_name: "Amina",
    last_name: "Bello",
    phone_number: "08040000004",
    bio: "Bags and fashion accessories.",
    verified: true
  },
  {
    email: "seller.chris@loopedt.test",
    password: "password123",
    username: "chris_tech",
    first_name: "Chris",
    last_name: "Adeyemi",
    phone_number: "08040000005",
    bio: "Electronics and tech accessories.",
    verified: true
  }
]

sellers = seller_records.map do |attributes|
  user = User.find_or_initialize_by(email: attributes[:email])

  user.assign_attributes(attributes)
  user.save!

  user
end

# Include original sample users as sellers too.

original_sellers = User.where(
  email: %w[
    janet@example.com
    john@example.com
    mary@example.com
  ]
)

sellers = (sellers + original_sellers.to_a).uniq

# ==========================================
# 2. APPROVE SELLER APPLICATIONS
# ==========================================

sellers.each do |seller|
  application = SellerApplication.find_or_initialize_by(
    user: seller
  )

  application.assign_attributes(
    shop_name: "#{seller.first_name}'s Loopedt Store",
    description: "A test seller shop on Loopedt.",
    location: "Lagos, Nigeria",
    status: "approved"
  )

  application.save!
end

# ==========================================
# 3. FIND CATEGORIES
# ==========================================

clothing = Category.find_by!(name: "Clothing")
shoes = Category.find_by!(name: "Shoes")
electronics = Category.find_by!(name: "Electronics")
accessories = Category.find_by!(name: "Accessories")

# ==========================================
# 4. UPDATE EXISTING INVENTORY
# ==========================================

puts "Updating existing listing inventory..."

updated_count = 0

Listing.where(status: "available").find_each do |listing|

  target_stock = [
    listing.stock_quantity,
    listing.reserved_quantity + 5,
    5
  ].max

  if listing.stock_quantity != target_stock
    listing.update!(stock_quantity: target_stock)
    updated_count += 1
  end
end

puts "Updated #{updated_count} existing listings."

# ==========================================
# 5. PRODUCT INVENTORY
# ==========================================

inventory = [
  {
    category: clothing,
    products: [
      ["Classic Cotton T-Shirt", 12000, "M", "White", "Good"],
      ["Relaxed Fit Linen Shirt", 18000, "L", "Beige", "Like New"],
      ["Straight Leg Denim Jeans", 25000, "32", "Blue", "Good"],
      ["Everyday Knit Cardigan", 22000, "M", "Cream", "Like New"],
      ["Wide Leg Trousers", 28000, "L", "Black", "New"],
      ["Vintage Graphic Hoodie", 30000, "XL", "Grey", "Good"]
    ]
  },

  {
    category: shoes,
    products: [
      ["Classic White Sneakers", 45000, "40", "White", "Good"],
      ["Running Trainers", 52000, "42", "Black", "Like New"],
      ["Leather Loafers", 48000, "41", "Brown", "Good"],
      ["Minimal Flat Sandals", 22000, "39", "Tan", "New"],
      ["Canvas High Top Shoes", 35000, "43", "Black", "Good"],
      ["Chelsea Ankle Boots", 65000, "42", "Brown", "Like New"]
    ]
  },

  {
    category: accessories,
    products: [
      ["Everyday Shoulder Bag", 32000, "Medium", "Brown", "Good"],
      ["Minimal Crossbody Bag", 28000, "Medium", "Black", "Like New"],
      ["Classic Sunglasses", 15000, nil, "Black", "New"],
      ["Leather Card Holder", 10000, nil, "Brown", "Good"],
      ["Canvas Tote Bag", 12000, nil, "Cream", "New"],
      ["Pendant Necklace", 18000, nil, "Gold", "Like New"]
    ]
  },

  {
    category: electronics,
    products: [
      ["Bluetooth Speaker", 38000, nil, "Black", "Like New"],
      ["Wireless Computer Mouse", 14000, nil, "Black", "New"],
      ["USB Desk Microphone", 42000, nil, "Black", "Good"],
      ["Portable Power Bank", 25000, nil, "White", "Like New"],
      ["Laptop Stand", 20000, nil, "Silver", "New"],
      ["Wireless Earbuds", 35000, nil, "White", "Good"]
    ]
  }
]

# ==========================================
# 6. CREATE SELLER LISTINGS
# ==========================================

created_count = 0

sellers.each_with_index do |seller, seller_index|

  inventory.each_with_index do |group, category_index|

    group[:products].each_with_index do |product, product_index|

      # Distribute products between sellers.

      next unless (
        product_index + category_index + seller_index
      ) % sellers.length == seller_index

      title, price, size, colour, condition = product

      listing_title = "#{title} - #{seller.username}"

      listing = Listing.find_or_initialize_by(
        user: seller,
        title: listing_title
      )

      listing.assign_attributes(
        category: group[:category],
        description: "#{title}, in #{condition.downcase} condition. Available from this Loopedt seller.",
        price: price,
        condition: condition,
        brand: "Loopedt Select",
        size: size,
        colour: colour,
        status: "available",
        stock_quantity: 3 + (
          (seller_index + product_index + category_index) % 8
        ),
        reserved_quantity: 0
      )

      was_new = listing.new_record?

      listing.save!

      created_count += 1 if was_new

    end
  end
end

# ==========================================
# 7. INVENTORY SUMMARY
# ==========================================

puts ""
puts "=========================================="
puts "LOOPEDT INVENTORY SEEDING COMPLETE"
puts "=========================================="

puts "Sellers: #{sellers.count}"

puts "Approved applications: #{
  SellerApplication.where(
    user: sellers,
    status: "approved"
  ).count
}"

puts "New listings: #{created_count}"

puts "Available listings: #{
  Listing.where(status: "available").count
}"

puts "Total available units: #{
  Listing.where(status: "available").sum(
    "stock_quantity - reserved_quantity"
  )
}"

puts "=========================================="

puts "TEST SELLER PASSWORD: password123"

seller_records.each do |seller|
  puts seller[:email]
end
