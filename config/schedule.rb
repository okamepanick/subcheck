set :environment, 'development'
set :output, 'log/cron.log'

# 毎日深夜に延滞請求日を更新する
every 1.day, at: '12:00 am' do
  rake 'subscriptions:update_billing_date'
end

# 正確なタイミングで通知するため、30分おきにリマインダー確認
every 30.minutes do
  rake 'subscriptions:send_reminders'
end

# 毎日 10:00 に実行されるタスクです。
# 明日請求日のサブスクを持つユーザーにLINEでリマインダー通知を送ります。
# たとえその日に対象ユーザーがいなくても、タスク自体は削除せず残しておく必要があります。
# → 将来サブスクが追加された場合でも自動で通知されるようにするため
# 明日請求日のユーザーにだけ通知する処理なので、対象ユーザーがいない日もタスク自体は毎日残しておく設計です
every 1.day, at: '10:00 am' do
  rake 'subscriptions:send_daily_reminders'
end
