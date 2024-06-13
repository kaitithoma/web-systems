# frozen_string_literal: true

require 'clockwork'
require 'clockwork/database_events'
require './config/boot'
require './config/environment'

# Clockwork configuration for scheduling tasks
module Clockwork
  configure do |config|
    config[:tz] = 'Europe/Athens'
    config[:max_threads] = 15
    config[:thread] = true
    config[:logger] = ActiveSupport::Logger.new(
      Rails.root.join('log', 'clockworkd.clockwork.output'), 10, 100.megabytes
    )
  end

  # required to enable database syncing support
  Clockwork.manager = DatabaseEvents::Manager.new
  sync_database_events(model: ::Schedule, every: 1.minute) do |schedule|
    schedule.job_name.constantize.set(queue: schedule.queue_name).delay.perform_later
  end
end
