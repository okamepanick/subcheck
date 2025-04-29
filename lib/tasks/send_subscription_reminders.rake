namespace :subscriptions do
  desc "サブスクの更新日が明日のユーザーにLINE通知を送る"
  task send_reminders: :environment do
    tomorrow = Date.tomorrow

    Subscription.where(next_billing_date: tomorrow).each do |subscription|
      user = subscription.user
      next unless user.line_user_id

      message = {
        type: 'text',
        text: "明日「#{subscription.service_name}」」の更新日です！"
      }

      client = Line::Bot::Client.new do |config|
        config.channel_secret = ENV['LINE_CHANNEL_SECRET']
        config.channel_token = ENV['LINE_CHANNEL_ACCESS_TOKEN']
      end

      client.push_message(user.line_user_id, message)
      puts "通知 sent to #{user.username} for #{subscription.service_name}"
    end
  end
end


