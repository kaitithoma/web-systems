# frozen_string_literal: true

class DelayedJob < ApplicationRecord
  self.table_name = 'delayed_jobs'
end
