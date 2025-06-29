set :environment, 'development'
set :output, 'log/cron.log'

# Update overdue billing dates daily at midnight
every 1.day, at: '12:00 am' do
  rake 'subscriptions:update_billing_dates'
end

# Run reminder checks every 30 minutes for precise timing
every 30.minutes do
  rake 'subscriptions:send_reminders'
end

# Keep the daily reminder as backup
every 1.day, at: '10:00 am' do
  rake 'subscriptions:send_daily_reminders'
end
