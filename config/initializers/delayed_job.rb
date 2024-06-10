# frozen_string_literal: true

# Delayed::Worker.logger = ActiveSupport::TaggedLogging.new(
#   Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'), 10, 100.megabytes)
# )
Delayed::Worker.max_run_time = 3.hours
Delayed::Worker.max_attempts = 3
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.delay_jobs = true
Delayed::Worker.default_queue_name = 'default'
# Delayed::Worker.queue_attributes = {
#   default: { priority: -15 }
# }
