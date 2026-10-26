class Api::SubscriptionsController < ApplicationController
  def index
    render json: Subscription.order(:id).map { |subscription|
        {
          id: subscription.id,
          serviceName: subscription.service_name,
          price: subscription.price,
          billingCycle: subscription.billing_cycle,
          startDate: subscription.start_date,
          nextBillingDate: subscription.next_billing_date,
          paymentMethod: subscription.payment_method
        }
      }
  end
end
