# frozen_string_literal: true

# to view cron rules - visit https://crontab.guru

# Call scheduled events
# At minute 0
every '0 * * * *' do
  runner 'SchedulerJob.perform_later'
end
