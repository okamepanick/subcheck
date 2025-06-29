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
    get liff_edit_subscription_path, params: { id: @subscription.id }
    assert_response :success
  end

  test "should create subscription via LIFF and render success page" do
    # Mock the LINE client to avoid actual API calls
    line_client_mock = mock('line_client')
    line_client_mock.expects(:push_message).once
    
    SubscriptionsController.any_instance.stubs(:line_client).returns(line_client_mock)
    
    assert_difference('Subscription.count') do
      post subscriptions_path, params: { 
        subscription: { 
          service_name: "Test Service",
          start_date: Date.today,
          next_billing_date: Date.today + 1.month,
          billing_cycle: "monthly",
          price: 1000,
          payment_method: "クレジットカード",
          line_user_id: @line_user.line_uid
        }
      }
    end
    assert_response :success
    assert_template :liff_success
  end

  test "should update subscription via LIFF and render success page" do
    # Mock the LINE client to avoid actual API calls
    line_client_mock = mock('line_client')
    line_client_mock.expects(:push_message).once
    
    SubscriptionsController.any_instance.stubs(:line_client).returns(line_client_mock)
    
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
    assert_response :success
    assert_template :liff_success_edit
  end
end
