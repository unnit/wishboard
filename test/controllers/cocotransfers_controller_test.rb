require 'test_helper'

class CocotransfersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cocotransfer = cocotransfers(:one)
  end

  test "should get index" do
    get cocotransfers_url
    assert_response :success
  end

  test "should get new" do
    get new_cocotransfer_url
    assert_response :success
  end

  test "should create cocotransfer" do
    assert_difference('Cocotransfer.count') do
      post cocotransfers_url, params: { cocotransfer: { amount: @cocotransfer.amount, payment_status: @cocotransfer.payment_status, showcase_id: @cocotransfer.showcase_id, status: @cocotransfer.status, transaction_status: @cocotransfer.transaction_status, txnid: @cocotransfer.txnid, user_id: @cocotransfer.user_id } }
    end

    assert_redirected_to cocotransfer_url(Cocotransfer.last)
  end

  test "should show cocotransfer" do
    get cocotransfer_url(@cocotransfer)
    assert_response :success
  end

  test "should get edit" do
    get edit_cocotransfer_url(@cocotransfer)
    assert_response :success
  end

  test "should update cocotransfer" do
    patch cocotransfer_url(@cocotransfer), params: { cocotransfer: { amount: @cocotransfer.amount, payment_status: @cocotransfer.payment_status, showcase_id: @cocotransfer.showcase_id, status: @cocotransfer.status, transaction_status: @cocotransfer.transaction_status, txnid: @cocotransfer.txnid, user_id: @cocotransfer.user_id } }
    assert_redirected_to cocotransfer_url(@cocotransfer)
  end

  test "should destroy cocotransfer" do
    assert_difference('Cocotransfer.count', -1) do
      delete cocotransfer_url(@cocotransfer)
    end

    assert_redirected_to cocotransfers_url
  end
end
