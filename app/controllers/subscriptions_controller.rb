class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, only: [:show, :edit, :update]
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  def index
    if user_signed_in?
      @subscriptions = current_user.subscriptions
      @subscriptions.map do |subscription|
        if subscription.next_billing_date < Date.today
          if subscription.monthly?
            subscription.update(next_billing_date: subscription.next_billing_date.next_month)
          elsif subscription.yearly?
            subscription.update(next_billing_date: subscription.next_billing_date.next_year)
          end
        end
      end
      monthly_total = @subscriptions.monthly.sum(:price)
      yearly_total = @subscriptions.yearly.sum(:price) / 12
      @total_amount = monthly_total + yearly_total
      earliest_date = @subscriptions.where("next_billing_date >= ?", Date.today).minimum(:next_billing_date)
      @next_subscriptions = @subscriptions.where(next_billing_date: earliest_date)
    end
  end

  def show

  end

  def new
    @subscription = Subscription.new
  end

  def create
    line_user_id = params[:subscription][:line_user_id]

    user = User.find_by(line_user_id: line_user_id)

    @subscription = Subscription.new(subscription_params)
    @subscription.user = user

    if @subscription.save
      redirect_to subscriptions_path, notice: "サブスクを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @subscription.update(subscription_params)
      redirect_to root_path, notice: "サブスクが正常に更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subscription.destroy
    redirect_to root_path, notice: "サブスクが正常に削除されました。"
  end

  private

  def subscription_params
    params.require(:subscription).permit(:service_name, :start_date, :next_billing_date, :billing_cycle, :price, :payment_method)
  end

  def set_subscription
    @subscription = current_user.subscriptions.find_by(id: params[:id])
    if @subscription.blank?
      redirect_to root_path
    end
  end
end
