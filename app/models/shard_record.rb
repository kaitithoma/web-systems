class ShardRecord < ApplicationRecord
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary },
    country1: { writing: :country1, reading: :country1 },
    country2: { writing: :country2, reading: :country2 }
  }
end
