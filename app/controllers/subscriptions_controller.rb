class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :show, :edit, :update]
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  def index
    if user_signed_in?
      @subscriptions = current_user.subscriptions
      monthly_total = current_user.subscriptions.monthly.sum(:price)
      yearly_total = current_user.subscriptions.yearly.sum(:price) / 12
      @total_amount = monthly_total + yearly_total
      earliest_date = current_user.subscriptions.where("next_billing_date >= ?", Date.today).minimum(:next_billing_date)
      @next_subscriptions = current_user.subscriptions.where(next_billing_date: earliest_date)

      @subscriptions.map do |subscription|
        if subscription.next_billing_date < Date.today
          if subscription.monthly?
            subscription.update(next_billing_date: subscription.next_billing_date.next_month)
          elsif subscription.yearly?
            subscription.update(next_billing_date: subscription.next_billing_date.next_year)
          end
        end
      end
    else
      @subscriptions = []
    end
  end

  def show

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

  def edit
  end

  def update
    if @subscription.update(subscription_params)
      redirect_to root_path, notice: "更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @subscription.destroy
    redirect_to root_path
  end

  private

  def subscription_params
    params.require(:subscription).permit(:service_name, :start_date, :next_billing_date, :billing_cycle, :price, :payment_method).merge(user_id: current_user.id)
  end

  def set_subscription
    @subscription = current_user.subscriptions.find_by(id: params[:id])
    if @subscription.blank?
      redirect_to root_path
    end
  end
end
