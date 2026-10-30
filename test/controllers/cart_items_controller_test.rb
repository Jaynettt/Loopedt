
require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @listing = listings(:two)

    # Log in using the test user's credentials.
    post login_path, params: {
      email: @user.email,
      password: "password123"
    }
  end

  test "should get index" do
    get cart_items_path

    assert_response :success
  end

  test "should create cart item" do
    new_listing = Listing.create!(
      user: users(:two),
      category: categories(:one),
      title: "Test listing",
      description: "A test listing",
      price: 25,
      condition: "Good",
      brand: "Test brand",
      size: "M",
      colour: "Black",
      status: "active"
    )

    assert_difference("CartItem.count", 1) do
      post cart_items_path, params: {
        listing_id: new_listing.id
      }
    end

    assert_redirected_to cart_items_path
  end

  test "should update cart item" do
    cart_item = @user.cart_items.first

    assert_not_nil cart_item

    patch cart_item_path(cart_item), params: {
      quantity: "2"
    }

    puts "Response status: #{response.status}"
    puts "Response location: #{response.location}"
    puts "Flash: #{flash.inspect}"
    puts "Quantity after update: #{cart_item.reload.quantity}"

    assert_redirected_to cart_items_path
    assert_equal 2, cart_item.reload.quantity
    end

  test "should destroy cart item" do
    cart_item = cart_items(:one)

    assert_difference("CartItem.count", -1) do
      delete cart_item_path(cart_item)
    end

    assert_redirected_to cart_items_path
  end
end
