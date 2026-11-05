ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :users,
            :categories,
            :listings,
            :checkouts,
            :looks,
            :conversations,
            :cart_items,
            :favorites,
            :orders,
            :look_items,
            :look_item_matches,
            :messages,
            :seller_applications,
            :negotiation_offers

    # Add more helper methods to be used by all tests here...
  end
end
