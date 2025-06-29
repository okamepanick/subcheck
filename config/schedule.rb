set :environment, 'development'
set :output, 'log/cron.log'

# Run reminder checks every 30 minutes for precise timing
every 30.minutes do
  rake 'subscriptions:send_reminders'
end

# Keep the daily reminder as backup
every 1.day, at: '10:00 am' do
  rake 'subscriptions:send_daily_reminders'
end
