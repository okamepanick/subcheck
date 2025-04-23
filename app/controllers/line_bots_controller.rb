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

        # ユーザーのLINEプロフィールを取得
        profile = client.get_profile(line_user_id)

        if profile.is_a?(Net::HTTPSuccess)
          profile_data = JSON.parse(profile.body)
          username = profile_data['displayName']  # LINEのユーザー名を取得
        else
          username = "default"  # プロフィールが取得できない場合はデフォルト名
        end

        # ユーザーが存在しない場合は、デフォルト値をセットして作成
        user = User.find_or_create_by(line_user_id: line_user_id) do |u|
          u.email = "line_#{SecureRandom.hex(4)}@example.com"
          u.username = username  # 取得したLINEのユーザー名を設定
          u.password = SecureRandom.hex(8)  # 適当な8文字のランダム文字列
        end

        Rails.logger.debug "User found or created: #{user.inspect}"
        Rails.logger.debug "User persisted?: #{user.persisted?}"

        unless user.persisted?
          Rails.logger.debug "User not saved: #{user.errors.full_messages}"
        end
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_ACCESS_TOKEN']
    end
  end
end
