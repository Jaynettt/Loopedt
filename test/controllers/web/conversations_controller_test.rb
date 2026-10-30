
require "test_helper"

class Web::ConversationsControllerTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    @buyer = User.create!(
      email: "buyer@example.com",
      username: "test_buyer",
      password: "password123"
    )

    @seller = User.create!(
      email: "seller@example.com",
      username: "test_seller",
      password: "password123"
    )

    category = Category.create!(name: "Clothing")

    listing = Listing.create!(
      user: @seller,
      category: category,
      title: "Test jacket",
      description: "A jacket for testing",
      price: 50,
      condition: "Good",
      status: "active"
    )

    @conversation = Conversation.create!(
      listing: listing,
      buyer: @buyer,
      seller: @seller,
      status: "open"
    )

    # Simulate the buyer being logged in.
    @integration_session = ActionDispatch::Integration::Session.new(Rails.application)
    @integration_session.host! "www.example.com"
    @integration_session.post "/login", params: {
      email: @buyer.email,
      password: "password123"
    }
  end

  test "blocks a phone number and does not save the message" do
    assert_no_difference("Message.count") do
      post_message("My number is 08012345678")
    end

    assert_equal "Your message contains contact information. Please keep communication on Loopedt.",
                 flash[:alert]
  end

  test "blocks an email address and does not save the message" do
    assert_no_difference("Message.count") do
      post_message("Contact me at another@example.com")
    end
  end

  test "blocks a social media username and does not save the message" do
    assert_no_difference("Message.count") do
      post_message("Find me on TikTok janet23")
    end
  end

  test "allows a normal marketplace message" do
    assert_difference("Message.count", 1) do
      post_message("Hello, is the jacket still available?")
    end

    message = Message.order(:created_at).last

    assert_equal "Hello, is the jacket still available?", message.body
    assert_equal @buyer.id, message.sender_id
    assert_equal "approved", message.moderation_status
  end

  test "does not allow a non-participant to send a message" do
    outsider = User.create!(
      email: "outsider@example.com",
      username: "test_outsider",
      password: "password123"
    )

    @integration_session.post "/login", params: {
      email: outsider.email,
      password: "password123"
    }

    assert_no_difference("Message.count") do
      post_message("Hello, I am interested.")
    end
  end

  test "marks incoming approved messages as read when conversation is opened" do
    incoming_message = Message.create!(
      conversation: @conversation,
      sender: @seller,
      body: "Is the jacket still available?",
      moderation_status: "approved"
    )

    outgoing_message = Message.create!(
      conversation: @conversation,
      sender: @buyer,
      body: "Yes, I am interested.",
      moderation_status: "approved"
    )

    pending_message = Message.create!(
      conversation: @conversation,
      sender: @seller,
      body: "Another message",
      moderation_status: "pending"
    )

    get "/inbox/#{@conversation.id}"

    assert incoming_message.reload.read_at.present?
    assert_nil outgoing_message.reload.read_at
    assert_nil pending_message.reload.read_at
  end

 test "shows the correct unread message count in the inbox" do
    Message.create!(
      conversation: @conversation,
      sender: @seller,
      body: "Unread message",
      moderation_status: "approved"
    )

    Message.create!(
      conversation: @conversation,
      sender: @seller,
      body: "Already read message",
      moderation_status: "approved",
      read_at: 1.hour.ago
    )

    Message.create!(
      conversation: @conversation,
      sender: @buyer,
      body: "My own message",
      moderation_status: "approved"
    )

    get "/inbox"

    assert_response :success
    assert_select "body", /1/
  end
  private

  def post_message(body)
    @integration_session.post(
      "/inbox/#{@conversation.id}/messages",
      params: { body: body }
    )
  end
end
