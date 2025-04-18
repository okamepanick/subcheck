class LineBotsController < ApplicationController
  protect_from_forgery with: :null_session  # WebhookなのでCSRF無効にしておく

  def callback
    Rails.logger.debug "Callback started"
    body = request.body.read
    events = client.parse_events_from(body)

    events.each do |event|
      Rails.logger.debug "Event: #{event.inspect}"
      case event
      when Line::Bot::Event::Follow
        line_user_id = event['source']['userId']
        Rails.logger.debug "Received Follow event. line_user_id: #{line_user_id}"

        # ユーザーが存在しない場合は、デフォルト値をセットして作成
        user = User.find_or_create_by(line_user_id: line_user_id) do |u|
          u.email = "line_#{SecureRandom.hex(4)}@example.com"
          u.username = "default"
          u.password = SecureRandom.hex(8)  # 適当な8文字のランダム文字列
        end

        Rails.logger.debug "User found or created: #{user.inspect}"
        Rails.logger.debug "User persisted?: #{user.persisted?}"

        unless user.persisted?
          Rails.logger.debug "User not saved: #{user.errors.full_messages}"
        end

      when Line::Bot::Event::Message
        handle_text_message(event)
      end
    end

    head :ok
  end

  private

  def handle_text_message(event)
    case event.message['text']
    when 'サブスク登録'
      text = "サブスク登録の処理を行います。"
    when 'リマインダー設定'
      text = "リマインダー設定を行います。"
    when '月額の合計確認'
      text = "月額の合計確認を行います。"
    when '新規会員登録'
      text = "新規会員登録の処理を行います。"
    when 'サブスク編集削除'
      text = "サブスク編集削除のページへ移動します。"
    when 'サブスク一覧'
      text = "サブスク一覧のページへ移動します。"
    else
      text = "その操作は認識できませんでした。"
    end

    message = { type: 'text', text: text }
    client.reply_message(event['replyToken'], message)
  end

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_ACCESS_TOKEN']
    end
  end
end
