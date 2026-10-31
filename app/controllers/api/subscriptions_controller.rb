class Api::SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_line_user

  def index
    render json: @line_user.subscriptions.order(:id).map { |subscription|
      subscription_json(subscription)
    }
  end

  def create
    subscription = @line_user.subscriptions.build(
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

  def set_line_user
    token = bearer_token
    if token.blank?
      render json: { error: "ログインが必要です" }, status: :unauthorized
      return
    end

    line_uid = line_uid_from_id_token(token)
    if line_uid.blank?
      render json: { error: "ログインの確認に失敗しました" }, status: :unauthorized
      return
    end

    @line_user = LineUser.find_by(line_uid: line_uid)
    unless @line_user
      render json: { error: "LINEユーザーが見つかりません" }, status: :unprocessable_entity
    end
  end

  def bearer_token
    header = request.authorization.to_s
    return if header.blank?

    header.delete_prefix("Bearer ").strip
  end

  def line_uid_from_id_token(token)
    uri = URI("https://api.line.me/oauth2/v2.1/verify")
    response = Net::HTTP.post_form(uri, {
      "id_token" => token,
      "client_id" => ENV["LINE_CHANNEL_ID"]
    })
    return unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)["sub"]
  rescue StandardError
    nil
  end

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
