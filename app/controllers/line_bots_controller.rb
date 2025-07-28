class LineBotsController < ApplicationController
  protect_from_forgery with: :null_session  # WebhookなのでCSRF無効にしておく

  def callback
    Rails.logger.debug "Callback started"
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end

    events = client.parse_events_from(body)

    events.each do |event|
      Rails.logger.debug "Event: #{event.inspect}"
      case event
      when Line::Bot::Event::Follow
        handle_follow_event(event)
      end
    end

    head :ok
  end

  private

  def handle_follow_event(event)
    line_user_id = event['source']['userId']
    Rails.logger.debug "Received Follow event. line_user_id: #{line_user_id}"

    profile = client.get_profile(line_user_id)

    if profile.is_a?(Net::HTTPSuccess)
      Rails.logger.debug "取得したプロフィールの生データ: #{profile.body}" # これを追加

      profile_data = JSON.parse(profile.body)
      display_name = profile_data['displayName']
      line_user = LineUser.find_or_initialize_by(line_uid: line_user_id)
      line_user.display_name = display_name
      line_user.save
    else
      Rails.logger.debug "プロフィール取得に失敗しました。"
    end
  end
end
