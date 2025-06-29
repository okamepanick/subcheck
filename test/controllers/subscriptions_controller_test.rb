require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @line_user = line_users(:one)
    @subscription = subscriptions(:one)
  end

  test "should get liff new" do
    get liff_new_subscription_path
    assert_response :success
  end

  test "should get liff edit" do
    get liff_edit_subscription_path(@subscription)
    assert_response :success
  end

  test "should update subscription via LIFF" do
    patch subscription_path(@subscription), params: { 
      subscription: { 
        service_name: "Updated Service",
        start_date: @subscription.start_date,
        next_billing_date: @subscription.next_billing_date,
        billing_cycle: @subscription.billing_cycle,
        price: 1999,
        payment_method: "クレジットカード",
        line_user_id: @line_user.line_uid
      }
    }
    assert_redirected_to root_path
  end
end
