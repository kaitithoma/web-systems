# frozen_string_literal: true

class RetailerProduct < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :site_id }

  # Get the best SALE price for any PACKAGE for this PRODUCT for the given STORE
  def best_deal_for_store(store); end

  belongs_to :product, optional: true
  belongs_to :retailer_brand, optional: true
  belongs_to :site
  belongs_to :retailer_brand, optional: true
  has_many :product_price_metrics

  delegate :name, to: :retailer_brand, prefix: true
  delegate :name, to: :product, prefix: true
end
