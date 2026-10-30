require "test_helper"

class Sellers::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sellers_dashboard_index_url
    assert_response :success
  end
end
