# frozen_string_literal: true

class RetailerCategory < ShardRecord
  validates :name, presence: true, uniqueness: { scope: :site_id }

  belongs_to :category, optional: true
  belongs_to :site
end
