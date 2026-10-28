class Api::SubscriptionsController < ApplicationController

  skip_before_action :verify_authenticity_token
  
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

   def create
    line_user = LineUser.first
    unless line_user
      render json: { error: "LINEユーザーが見つかりません" }, status: :unprocessable_entity
      return
    end
    subscription = line_user.subscriptions.build(
      service_name: params[:serviceName],
      price: params[:price],
      billing_cycle: params[:billingCycle],
      start_date: params[:startDate],
      next_billing_date: params[:nextBillingDate],
      payment_method: params[:paymentMethod]
    )
    if subscription.save
      render json: subscription_json(subscription), status: :created
    else
      render json: { error: subscription.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private
  def subscription_json(subscription)
    {
      id: subscription.id,
      serviceName: subscription.service_name,
      price: subscription.price,
      billingCycle: subscription.billing_cycle,
      startDate: subscription.start_date,
      nextBillingDate: subscription.next_billing_date,
      paymentMethod: subscription.payment_method
    }
  end
end
