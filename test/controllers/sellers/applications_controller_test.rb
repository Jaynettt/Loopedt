require "test_helper"

class Sellers::ApplicationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sellers_applications_new_url
    assert_response :success
  end

  test "should get create" do
    get sellers_applications_create_url
    assert_response :success
  end
end
