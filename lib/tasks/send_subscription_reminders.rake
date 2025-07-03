namespace :subscriptions do
  desc "サブスクのリマインダー通知を送る"
  task send_reminders: :environment do
    now = Time.current
    
    # 16時間前の通知
    send_reminders_for_interval(16.hours, "16時間後に「{service_name}」の更新日です！")
    
    # 8時間前の通知
    send_reminders_for_interval(8.hours, "8時間後に「{service_name}」の更新日です！")
    
    # 2時間前の通知
    send_reminders_for_interval(2.hours, "2時間後に「{service_name}」の更新日です！")
    
    # 30分前の通知
    send_reminders_for_interval(30.minutes, "30分後に「{service_name}」の更新日です！")
  end

  desc "期限切れのサブスクのnext_billing_dateを自動更新する"
  task update_billing_dates: :environment do
    Rails.logger.info "Starting billing date update task..."
    
    updated_count = 0
    Subscription.where("next_billing_date < ?", Date.today).find_each do |subscription|
      old_date = subscription.next_billing_date
      subscription.update_billing_date_if_overdue
      subscription.reload
      
      if subscription.next_billing_date != old_date
        updated_count += 1
        Rails.logger.info "Updated #{subscription.service_name} (ID: #{subscription.id}) from #{old_date} to #{subscription.next_billing_date}"
      end
    end
    
    Rails.logger.info "Billing date update task completed. Updated #{updated_count} subscriptions."
  end
  
  desc "サブスクの更新日が明日のユーザーにLINE通知を送る（旧版・後方互換性）"
  task send_daily_reminders: :environment do
    tomorrow = Date.tomorrow

    Subscription.joins(:line_user).where(next_billing_date: tomorrow).where.not(line_users: { line_uid: nil }).each do |subscription|
      line_user = subscription.line_user

      message = {
        type: 'text',
        text: "明日「#{subscription.service_name}」の更新日です！"
      }

      client = Line::Bot::Client.new do |config|
        config.channel_secret = ENV['LINE_CHANNEL_SECRET']
        config.channel_token = ENV['LINE_CHANNEL_ACCESS_TOKEN']
      end

      begin
        client.push_message(line_user.line_uid, message)
        Rails.logger.info "Reminder sent to #{line_user.line_uid} for #{subscription.service_name}"
      rescue => e
        Rails.logger.error "Failed to send reminder: #{e.message}"
      end
    end
  end
end

def send_reminders_for_interval(interval, message_template)
  target_time = Time.current + interval
  target_date = target_time.to_date
  
  # 対象の日付のサブスクリプションを取得
  subscriptions = Subscription.joins(:line_user)
                              .where(next_billing_date: target_date)
                              .where.not(line_users: { line_uid: nil })
  
  subscriptions.each do |subscription|
    line_user = subscription.line_user
    
    # 実際の請求日時を計算（仮に00:00とする）
    billing_datetime = subscription.next_billing_date.beginning_of_day
    time_until_billing = billing_datetime - Time.current
    
    # 指定された間隔の範囲内かチェック（±30分の誤差を許容）
    if (time_until_billing - interval).abs <= 30.minutes
      message_text = message_template.gsub('{service_name}', subscription.service_name)
      
      message = {
        type: 'text',
        text: message_text
      }

      client = Line::Bot::Client.new do |config|
        config.channel_secret = ENV['LINE_CHANNEL_SECRET']
        config.channel_token = ENV['LINE_CHANNEL_ACCESS_TOKEN']
      end

      begin
        client.push_message(line_user.line_uid, message)
        Rails.logger.info "#{interval.inspect} reminder sent to #{line_user.line_uid} for #{subscription.service_name}"
      rescue => e
        Rails.logger.error "Failed to send #{interval.inspect} reminder: #{e.message}"
      end
    end
  end
end
