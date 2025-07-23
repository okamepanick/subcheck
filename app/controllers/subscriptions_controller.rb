class SubscriptionsController < ApplicationController
  # before_action :authenticate_admin_user!, except: [:liff_new, :liff_edit]
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  layout 'liff', only: [:liff_new]

  def index
    if params[:line_user_id]
      line_user = LineUser.find_by(id: params[:line_user_id])
      if line_user
        @subscriptions = line_user.subscriptions
      else
        @subscriptions = []
      end
    else
      @subscriptions = []
    end

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

  def show

  end

  def new
    @subscription = Subscription.new
  end

  def create
    line_user_id = params[:subscription][:line_user_id]

    user = User.find_by(line_user_id: line_user_id)

    @subscription = user.subscriptions.build(subscription_params)

    if @subscription.save
      redirect_to root_path, notice: "サブスクが正常に登録されました。"
    else
      render :new, status: :unprocessable_entity #HTTPステータスを明示的にするためにunprocessable_entityを書いた（入力に不正があるから。）
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

  # LIFF methods for LINE integration
  def liff_new
    @subscription = Subscription.new
    render :liff_new
  end

  private

  def subscription_params
    params.require(:subscription).permit(:service_name, :start_date, :next_billing_date, :billing_cycle, :price, :payment_method)
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
    if @subscription.blank?
      redirect_to root_path
    end
  end
end
