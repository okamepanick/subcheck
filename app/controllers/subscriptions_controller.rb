class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  def index
    @subscriptions = Subscription.all
    @total_amount = Subscription.all.sum(:price)
    @next_subscription = Subscription.order(next_billing_date: "asc").first
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save
      redirect_to root_path, notice: "登録されました"
    else
      render :new
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:service_name, :start_date, :next_billing_date, :billing_cycle, :price, :payment_method).merge(user_id: current_user.id)
  end
end
