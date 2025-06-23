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
        handle_follow_event(event)
      when Line::Bot::Event::Message
        handle_message_event(event)
      when Line::Bot::Event::Postback
        handle_postback_event(event)
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
      profile_data = JSON.parse(profile.body)
      username = profile_data['displayName']
      user = User.find_or_create_by(line_user_id: line_user_id) do |u|
        u.email = "line_#{SecureRandom.hex(4)}@example.com"
        u.username = username
        u.password = line_user_id[0, 8]
      end
    else
      Rails.logger.debug "プロフィール取得に失敗しました。"
    end
  end

  def handle_message_event(event)
    return unless event.type == Line::Bot::Event::MessageType::Text
    
    line_user_id = event['source']['userId']
    user = User.find_by(line_user_id: line_user_id)
    return unless user
    
    message_text = event.message['text']
    Rails.logger.debug "Received message: #{message_text} from user: #{line_user_id}"
    
    case message_text
    when 'サブスク登録'
      handle_subscription_register(event, user)
    when 'サブスク編集'
      handle_subscription_edit(event, user)
    when 'サブスク削除'
      handle_subscription_delete(event, user)
    when 'サブスク一覧'
      handle_subscription_list(event, user)
    end
  end
  
  def handle_postback_event(event)
    line_user_id = event['source']['userId']
    user = User.find_by(line_user_id: line_user_id)
    return unless user
    
    postback_data = event['postback']['data']
    Rails.logger.debug "Received postback: #{postback_data} from user: #{line_user_id}"
    
    if postback_data.start_with?('edit_subscription_')
      subscription_id = postback_data.split('_').last
      handle_subscription_edit_selected(event, user, subscription_id)
    elsif postback_data.start_with?('delete_subscription_')
      subscription_id = postback_data.split('_').last
      handle_subscription_delete_selected(event, user, subscription_id)
    end
  end
  
  def handle_subscription_register(event, user)
    if ENV['SUBSCRIPTION_CREATE_LIFF_ID'].present?
      liff_url = "https://liff.line.me/#{ENV['SUBSCRIPTION_CREATE_LIFF_ID']}"
      
      message = {
        type: 'template',
        altText: 'サブスク登録',
        template: {
          type: 'buttons',
          text: 'サブスクを新規登録します',
          actions: [
            {
              type: 'uri',
              label: '登録フォームを開く',
              uri: liff_url
            }
          ]
        }
      }
    else
      message = {
        type: 'text',
        text: "登録機能は現在利用できません。LIFF IDが設定されていません。"
      }
    end
    
    client.reply_message(event['replyToken'], message)
  end
  
  def handle_subscription_edit(event, user)
    subscriptions = user.subscriptions
    
    if subscriptions.empty?
      message = {
        type: 'text',
        text: '登録されているサブスクがありません。'
      }
      client.reply_message(event['replyToken'], message)
      return
    end
    
    if subscriptions.count == 1
      # 1つだけの場合は直接編集画面へ
      handle_subscription_edit_selected(event, user, subscriptions.first.id)
      return
    end
    
    # 複数ある場合は選択肢を表示
    actions = subscriptions.limit(4).map do |subscription|
      {
        type: 'postback',
        label: subscription.service_name,
        data: "edit_subscription_#{subscription.id}"
      }
    end
    
    message = {
      type: 'template',
      altText: '編集するサブスクを選択してください',
      template: {
        type: 'buttons',
        text: '編集するサブスクを選択してください',
        actions: actions
      }
    }
    
    client.reply_message(event['replyToken'], message)
  end
  
  def handle_subscription_delete(event, user)
    subscriptions = user.subscriptions
    
    if subscriptions.empty?
      message = {
        type: 'text',
        text: '登録されているサブスクがありません。'
      }
      client.reply_message(event['replyToken'], message)
      return
    end
    
    if subscriptions.count == 1
      # 1つだけの場合は直接削除
      handle_subscription_delete_selected(event, user, subscriptions.first.id)
      return
    end
    
    # 複数ある場合は選択肢を表示
    actions = subscriptions.limit(4).map do |subscription|
      {
        type: 'postback',
        label: subscription.service_name,
        data: "delete_subscription_#{subscription.id}"
      }
    end
    
    message = {
      type: 'template',
      altText: '削除するサブスクを選択してください',
      template: {
        type: 'buttons',
        text: '削除するサブスクを選択してください',
        actions: actions
      }
    }
    
    client.reply_message(event['replyToken'], message)
  end
  
  def handle_subscription_list(event, user)
    subscriptions = user.subscriptions
    
    if subscriptions.empty?
      message = {
        type: 'text',
        text: '登録されているサブスクがありません。'
      }
      client.reply_message(event['replyToken'], message)
      return
    end
    
    # サブスク情報をテキストで表示
    text = "現在登録されているサブスク一覧:\n\n"
    
    subscriptions.each_with_index do |subscription, index|
      text += "#{index + 1}. #{subscription.service_name}\n"
      text += "   開始日: #{subscription.formatted_start_date}\n"
      text += "   次回請求日: #{subscription.formatted_next_billing_date}\n"
      text += "   支払いサイクル: #{subscription.billing_cycle_text}\n"
      text += "   料金: ¥#{subscription.price.to_s(:delimited)}\n"
      text += "   支払い方法: #{subscription.payment_method}\n\n"
    end
    
    # 月額合計を計算
    monthly_total = subscriptions.monthly.sum(:price)
    yearly_total = subscriptions.yearly.sum(:price) / 12
    total_amount = monthly_total + yearly_total
    
    text += "月額換算合計: ¥#{total_amount.to_s(:delimited)}"
    
    message = {
      type: 'text',
      text: text
    }
    
    client.reply_message(event['replyToken'], message)
  end
  
  def handle_subscription_edit_selected(event, user, subscription_id)
    subscription = user.subscriptions.find_by(id: subscription_id)
    return unless subscription
    
    # 編集用のLIFF URLを生成（編集用のLIFF IDが必要）
    if ENV['SUBSCRIPTION_EDIT_LIFF_ID'].present?
      liff_url = "https://liff.line.me/#{ENV['SUBSCRIPTION_EDIT_LIFF_ID']}?id=#{subscription.id}"
      
      message = {
        type: 'template',
        altText: "#{subscription.service_name}の編集",
        template: {
          type: 'buttons',
          text: "#{subscription.service_name}を編集します",
          actions: [
            {
              type: 'uri',
              label: '編集フォームを開く',
              uri: liff_url
            }
          ]
        }
      }
    else
      message = {
        type: 'text',
        text: "編集機能は現在利用できません。LIFF IDが設定されていません。"
      }
    end
    
    client.reply_message(event['replyToken'], message)
  end
  
  def handle_subscription_delete_selected(event, user, subscription_id)
    subscription = user.subscriptions.find_by(id: subscription_id)
    return unless subscription
    
    service_name = subscription.service_name
    
    if subscription.destroy
      message = {
        type: 'text',
        text: "#{service_name}のサブスクを削除しました。"
      }
    else
      message = {
        type: 'text',
        text: "削除に失敗しました。もう一度お試しください。"
      }
    end
    
    client.reply_message(event['replyToken'], message)
  end

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_ACCESS_TOKEN']
    end
  end
end
