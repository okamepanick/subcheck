class SubscriptionsController < ApplicationController
  #before_action :authenticate_admin_user!, except: [:liff_new, :liff_edit]
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  before_action :set__subscription_for_liff, only: [:liff_edit]

  layout 'liff', only: [:liff_new, :liff_edit]

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

    # @subscriptions にある、このユーザーのサブスク全てに対して、期限切れの請求日があれば請求日を更新する処理を実行する
    @subscriptions.each(&:update_billing_date_if_overdue)

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
    if params[:subscription].present? && params[:subscription][:line_user_id].present?
      line_user_id = params[:subscription][:line_user_id]
      #LIFFアプリからのリクエストであることを確認し、LINEユーザーIDからユーザーを取得する
      line_user = LineUser.find_by(line_uid: line_user_id)
      unless line_user
        render json: { error: "ユーザーが見つかりませんでした。" }, status: :unprocessable_entity
        return
      end

      @subscription = line_user.subscriptions.build(subscription_params)

      if @subscription.save
        #LINEで完了メッセージとサブスクリプションの詳細を送信する
        send_subscription_created_message(line_user, @subscription)
        #AJAXリクエストに対して、成功したことを示すレスポンスを返す
        render json: { success: true, message: "サブスクの登録が完了しました！" }
      else
        render json: { error: @subscription.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    else
      #LIFF（LINE）からのリクエストではない普通のWebフォームからの登録処理
      @subscription = Subscription.new(subscription_params)
      if @subscription.save
        redirect_to root_path, notice: "サブスクが正常に登録されました。"
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
  end

  def update
    #LINEユーザーの更新処理を扱う
    if params[:subscription][:line_user_id].present?
      line_user_id = params[:subscription][:line_user_id]
      line_user = LineUser.find_by(line_uid: line_user_id)
      @subscription = line_user.subscriptions.find_by(id: params[:id]) if line_user
    end

    if @subscription&.update(subscription_params)
      #このリクエストが LINE の LIFF アプリから送られたものか確認
      if params[:subscription][:line_user_id].present?
        #LINEで完了メッセージと更新済みサブスク情報を送る
        send_subscription_updated_message(line_user, @subscription)
        #AJAX 用の成功レスポンスを返す
        render json: { success: true, message: "サブスクの更新が完了しました！"}
      else
        redirect_to root_path, notice: "サブスクが正常に更新されました。"
      end
    else
      if params[:subscription][:line_user_id].present?
        render json: {error: @subscription.errors.full_messages.join(", ")}, status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @subscription.destroy
    redirect_to root_path, notice: "サブスクが正常に削除されました。"
  end

  # LINE連携のための LIFF メソッド
  def liff_new
    @subscription = Subscription.new
    render :liff_new
  end

  def liff_edit
    render :liff_edit
  end

  private

  def send_subscription_created_message(line_user, subscription)
    #完了メッセージを送信する
    completion_message = {
      type: "text",
      text: "サブスクの登録が完了しました！"
    }

    # サブスク登録情報のテキストを作成する
    details_text = "登録内容:\n\n"
    details_text += "サービス名: #{subscription.service_name}\n"
    details_text += "開始日: #{subscription.start_date.strftime('%Y年%m月%d日')}\n"
    details_text += "次回請求日: #{subscription.next_billing_date.strftime('%Y年%m月%d日')}\n"
    details_text += "支払いサービス: #{subscription.billing_cycle == 'monthly' ? '月払い' : '年払い'}\n"
    details_text += "料金: ¥#{subscription.price.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}\n"
    details_text += "支払い方法: #{subscription.payment_method}"

    details_messages = {
      type: "text",
      text: details_text
    }

    # 完了メッセージと詳細メッセージを一緒に送信
    line_client.push_message(line_user.line_uid, [completion_message, details_messages])
  end

  def send_subscription_updated_message(line_user, subscription)
    #完了メッセージを送信する
    completion_message = {
      type: "text",
      text: "サブスクの更新が完了しました！"
    }

    #サブスク更新情報のテキストを作成する
    details_text = "更新内容:\n\n"
    details_text += "サービス名: #{subscription.service_name}\n"
    details_text += "開始日: #{subscription.start_date.strftime('%Y年%m月%d日')}\n"
    details_text += "次回請求日: #{subscription.next_billing_date.strftime('%Y年%m月%d日')}\n"
    details_text += "支払いサイクル: #{subscription.billing_cycle == 'monthly' ? '月払い' : '年払い'}\n"
    details_text += "料金 : ¥#{subscription.price.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}\n"
    details_text += "支払い方法: #{subscription.payment_method}"

    details_messages = {
      type: "text",
      text: details_text
    }

    # 完了メッセージと詳細メッセージを一緒に送信
    line_client.push_message(line_user.line_uid, [completion_message, details_messages])
  end

  def line_client
    @line_client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_ACCESS_TOKEN']
    end
  end

  def subscription_params
    params.require(:subscription).permit(:service_name, :start_date, :next_billing_date, :billing_cycle, :price, :payment_method)
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
    if @subscription.blank?
      redirect_to root_path
    end
  end

  #まずクエリパラメータからIDを取得しようとし、その後に liff.state を取得する
  def set__subscription_for_liff
    id = params[:id]
    if id.blank? && params["liff.state"].present?
      match = params["liff.state"].match(/id=(\d+)/)
      id = match[1] if match
    end

    @subscription = Subscription.find_by(id: id) if id.present?
    if @subscription.blank?
      redirect_to root_path
    end
  end
end
