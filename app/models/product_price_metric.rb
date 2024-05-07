# frozen_string_literal: true

class ProductPriceMetric < ApplicationRecord
  belongs_to :retailer_product

  validates :price, presence: true
  validates :price, numericality: { greater_than: 0 }

  delegate :name, to: :retailer_product, prefix: true
end
