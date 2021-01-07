require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get '/', headers: { host: Settings.main_hostname }
    assert_response :success
    assert_match 'Home', @response.body
  end

  test "site subdomain routes correctly" do
    get '/', headers: { host: "foo.#{Settings.main_hostname}" }
    assert_response :success
    assert_match 'todo', @response.body
  end
end
