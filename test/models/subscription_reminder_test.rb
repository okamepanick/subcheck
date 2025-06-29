require "test_helper"

class SubscriptionReminderTest < ActiveSupport::TestCase
  def setup
    @line_user = line_users(:one)
    @subscription = subscriptions(:one)
  end

  test "should find subscriptions for reminder" do
    # Set up a subscription with next billing date tomorrow
    @subscription.update(next_billing_date: Date.tomorrow)
    
    # Check that the subscription is found in our scope
    tomorrow_subscriptions = Subscription.joins(:line_user)
                                        .where(next_billing_date: Date.tomorrow)
                                        .where.not(line_users: { line_uid: nil })
    
    assert_includes tomorrow_subscriptions, @subscription
  end

  test "should format reminder message correctly" do
    message_template = "16時間後に「{service_name}」の更新日です！"
    expected_message = "16時間後に「#{@subscription.service_name}」の更新日です！"
    
    actual_message = message_template.gsub('{service_name}', @subscription.service_name)
    
    assert_equal expected_message, actual_message
  end
end