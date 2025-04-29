set :environment, 'development'
set :output, 'log/cron.log'

every 1.day, at: '10:00 am' do
  rake 'subscriptions:send_reminders'
end