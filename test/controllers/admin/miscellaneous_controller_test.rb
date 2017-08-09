require 'test_helper'

class Admin::MiscellaneousControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_miscellaneous_index_url
    assert_response :success
  end

end
