# frozen_string_literal: true

class Schedule < ApplicationRecord
  validates :name, :frequency, :job_name, presence: true
  validates :name, uniqueness: true
  validate :job_exists, if: :job_name?

  # empty string in tz breaks the scheduler
  before_save do
    self.tz = nil if tz.blank?
  end

  def queue
    job_with_queue&.perform_later(job_arguments || {})
  end

  def if?(time)
    active? && environment_valid? && valid_day_month?(time)
  end

  protected

  def job_with_queue
    return job_class if queue_name.blank?

    job_class&.set(queue: queue_name)
  end

  def job_class

    # binding.pry

    ApplicationJob.descendants.find do |subclass|
      subclass.name == job_name
    end
  end

  def job_exists
    return true unless job_class.blank?

    errors.add(:job_name, 'Must specify a subclass of ApplicationJob')
  end

  def environment_valid?
    environments.blank? || environments.include?(Rails.env)
  end

  def valid_day_month?(time)
    return true unless day.present? || month.present?

    valid_day?(time) && valid_month?(time)
  end

  def valid_day?(time)
    return true unless day.present?

    time.day == day
  end

  def valid_month?(time)
    return true unless month.present?

    time.month == month
  end
end
