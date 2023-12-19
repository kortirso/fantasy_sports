# frozen_string_literal: true

# to view cron rules - visit https://crontab.guru

# Call scheduled events
# At minute 0 and 30
every '0,30 * * * *' do
  runner 'SchedulerJob.perform_later'
end

# At minute 0 past hour 0 and 12
every '0 0,12 * * *' do
  runner 'Weeks::BenchSubstitutionsJob.perform_later'
end

# Clear expired things
every 1.day do
  runner 'Users::Sessions::RemoveExpiredJob.perform_later'
  runner 'Injuries::RemoveExpiredJob.perform_later'
end

every 1.hour do
  runner 'Deliveries::User::DeadlineReportJob.perform_later'
end
