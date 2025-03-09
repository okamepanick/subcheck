class SubscriptionsController < ApplicationController
  def index
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = current_user.subscriptions.new(subscription_params)
    if @subscription.save
      redirect_to root_path, notice: "登録されました"
    else
      render :new
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:service_name, :start_date, :next_billing_date, :billing_cycle, :price, :payment_method)
  end
end
