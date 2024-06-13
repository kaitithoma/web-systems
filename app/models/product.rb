# frozen_string_literal: true

class Product < ShardRecord
  include PgSearch::Model

  belongs_to :brand, optional: true
  belongs_to :category, optional: true
  has_many :retailer_products
  has_many :product_price_metrics, through: :retailer_products

  delegate :name, to: :brand, prefix: true, allow_nil: true
  delegate :name, to: :category, prefix: true, allow_nil: true

  pg_search_scope :search_text, against: %i[name aliases], ignoring: :accents,
                                using: { tsearch: { prefix: true, tsvector_column: 'searchable' } }

  def prices_per_site
    retailer_products.map(&:last_price)
  end

  def lowest_price_history
    product_price_metrics.order(:price).pluck(:price)
  end
end
