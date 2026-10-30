
require "test_helper"

class MessageFilterTest < ActiveSupport::TestCase
   self.fixture_table_names = []
  test "allows normal marketplace messages" do
    messages = [
      "Hello, is the item still available?",
      "What sizes do you have?",
      "Can you deliver to Lagos?",
      "Can you reduce the price?",
      "I love Instagram and TikTok."
    ]

    messages.each do |message|
      result = MessageFilter.new(message).call
      assert_not result.blocked, "Unexpectedly blocked: #{message}"
    end
  end

  test "blocks phone numbers" do
    messages = [
      "My number is 08012345678",
      "Call me on +234 801 234 5678"
    ]

    messages.each do |message|
      assert MessageFilter.new(message).call.blocked,
             "Expected phone number to be blocked: #{message}"
    end
  end

  test "blocks phone numbers written in words" do
    messages = [
      "zero eight zero one two three four five six seven eight",
      "oh eight zero one two three four five six seven eight"
    ]

    messages.each do |message|
      assert MessageFilter.new(message).call.blocked,
             "Expected number in words to be blocked: #{message}"
    end
  end

  test "blocks email addresses" do
    messages = [
      "My email is janet@gmail.com",
      "Send me an email at janet@example.com"
    ]

    messages.each do |message|
      assert MessageFilter.new(message).call.blocked,
             "Expected email to be blocked: #{message}"
    end
  end

  test "blocks social media handles and usernames" do
    messages = [
      "Follow me @janet_23",
      "My Instagram username is janet_23",
      "Find me on TikTok janet23"
    ]

    messages.each do |message|
      assert MessageFilter.new(message).call.blocked,
             "Expected social username to be blocked: #{message}"
    end
  end

  test "blocks requests for contact information" do
    messages = [
      "Can I have your phone number?",
      "What's your WhatsApp?",
      "Give me your Instagram handle",
      "Where do you live?",
      "Can you send me your home address?",
      "What's your email?",
      "Drop your digits",
      "Share your socials",
      "Can we talk outside this app?",
      "Let's chat on WhatsApp"
    ]

    messages.each do |message|
      assert MessageFilter.new(message).call.blocked,
             "Expected contact request to be blocked: #{message}"
    end
  end

  test "blocks external contact links" do
    messages = [
      "Visit https://instagram.com/janet",
      "Check my website at www.example.com",
      "Message me at t.me/janet"
    ]

    messages.each do |message|
      assert MessageFilter.new(message).call.blocked,
             "Expected external link to be blocked: #{message}"
    end
  end

  test "allows ordinary delivery discussions" do
    messages = [
      "Do you deliver to Lagos?",
      "I live in Lekki, can you deliver there?",
      "What is your delivery fee?",
      "Can I collect the item tomorrow?"
    ]

    messages.each do |message|
      result = MessageFilter.new(message).call
      assert_not result.blocked, "Unexpectedly blocked: #{message}"
    end
  end
end
