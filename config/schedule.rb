# frozen_string_literal: true

# to view cron rules - visit https://crontab.guru

# Call scheduled events
# At minute 0 and 30
every '0,30 * * * *' do
  runner 'SchedulerJob.perform_later'
end

# Clear expired users sessions
every 1.day do
  runner 'Users::Sessions::RemoveExpiredJob.perform_later'
end
