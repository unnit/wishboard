require 'test_helper'

class Admin::CocotransfersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_cocotransfers_index_url
    assert_response :success
  end

end
