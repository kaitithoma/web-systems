# frozen_string_literal: true

class RetailerProductPriceMetric < ApplicationRecord
  belongs_to :retailer_product, optional: true
  belongs_to :retailer_category, optional: true
  belongs_to :site
  belongs_to :retailer_brand, optional: true
  belongs_to :product, optional: true
  has_many :product_price_metrics, dependent: :restrict_with_error

  validates :price_data, presence: true
  validates :product_name, presence: true, uniqueness: { scope: %i[site_id date product_name] }
  validates :category_name, presence: true
  validates :date, presence: true, uniqueness: { scope: %i[site_id product_name] }

  validates :retailer_product_id, uniqueness: { scope: %i[site_id retailer_brand_id] }
end
