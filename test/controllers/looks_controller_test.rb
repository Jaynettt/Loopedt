require "test_helper"

class LooksControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get looks_new_url
    assert_response :success
  end

  test "should get create" do
    get looks_create_url
    assert_response :success
  end

  test "should get show" do
    get looks_show_url
    assert_response :success
  end
end
