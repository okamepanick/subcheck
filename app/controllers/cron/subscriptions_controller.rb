class Cron::SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_daily_reminders_job
    Rake::Task['subscriptions:send_daily_reminders'].reenable
    Rake::Task['subscriptions:send_daily_reminders'].invoke
    render plain: "send_daily_reminders executed"
  end

  def update_billing_date_job
    Rake::Task['subscriptions:update_billing_date'].reenable
    Rake::Task['subscriptions:update_billing_date'].invoke
    render plain: "update_billing_date executed"
  end
end
