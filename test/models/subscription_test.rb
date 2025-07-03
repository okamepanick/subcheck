require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  test "update_billing_date_if_overdue updates monthly subscription correctly" do
    subscription = subscriptions(:one)
    subscription.update!(
      billing_cycle: "monthly",
      next_billing_date: 1.month.ago
    )
    
    old_date = subscription.next_billing_date
    subscription.update_billing_date_if_overdue
    subscription.reload
    
    assert_equal old_date.next_month, subscription.next_billing_date
  end

  test "update_billing_date_if_overdue updates yearly subscription correctly" do
    subscription = subscriptions(:one)
    subscription.update!(
      billing_cycle: "yearly",
      next_billing_date: 1.year.ago
    )
    
    old_date = subscription.next_billing_date
    subscription.update_billing_date_if_overdue
    subscription.reload
    
    assert_equal old_date.next_year, subscription.next_billing_date
  end

  test "update_billing_date_if_overdue does not update future dates" do
    subscription = subscriptions(:one)
    subscription.update!(
      billing_cycle: "monthly",
      next_billing_date: 1.month.from_now
    )
    
    old_date = subscription.next_billing_date
    subscription.update_billing_date_if_overdue
    subscription.reload
    
    assert_equal old_date, subscription.next_billing_date
  end

  test "update_billing_date_if_overdue does not update today's date" do
    subscription = subscriptions(:one)
    subscription.update!(
      billing_cycle: "monthly",
      next_billing_date: Date.today
    )
    
    old_date = subscription.next_billing_date
    subscription.update_billing_date_if_overdue
    subscription.reload
    
    assert_equal old_date, subscription.next_billing_date
  end

  test "update_all_overdue_billing_dates updates multiple overdue subscriptions" do
    # Create overdue monthly subscription
    monthly_sub = subscriptions(:one)
    monthly_sub.update!(
      billing_cycle: "monthly",
      next_billing_date: 2.months.ago
    )
    
    # Create overdue yearly subscription
    yearly_sub = subscriptions(:two)
    yearly_sub.update!(
      billing_cycle: "yearly", 
      next_billing_date: 1.year.ago
    )
    
    # Create non-overdue subscription
    future_sub = Subscription.create!(
      service_name: "Future Service",
      start_date: Date.today,
      next_billing_date: 1.month.from_now,
      billing_cycle: "monthly",
      price: 1000,
      payment_method: "Credit Card",
      line_user: line_users(:one)
    )
    
    old_monthly_date = monthly_sub.next_billing_date
    old_yearly_date = yearly_sub.next_billing_date
    old_future_date = future_sub.next_billing_date
    
    Subscription.update_all_overdue_billing_dates
    
    monthly_sub.reload
    yearly_sub.reload
    future_sub.reload
    
    # Overdue subscriptions should be updated
    assert_equal old_monthly_date.next_month, monthly_sub.next_billing_date
    assert_equal old_yearly_date.next_year, yearly_sub.next_billing_date
    
    # Future subscription should remain unchanged
    assert_equal old_future_date, future_sub.next_billing_date
  end

  test "billing_cycle_text returns correct Japanese text" do
    monthly_sub = subscriptions(:one)
    monthly_sub.update!(billing_cycle: "monthly")
    assert_equal "1ヶ月", monthly_sub.billing_cycle_text
    
    yearly_sub = subscriptions(:two)
    yearly_sub.update!(billing_cycle: "yearly")
    assert_equal "1年", yearly_sub.billing_cycle_text
  end
end
