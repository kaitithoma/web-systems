# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :brand, optional: true
  has_many :retailer_products
  has_many :product_price_metrics, through: :retailer_products

  delegate :name, to: :brand, prefix: true
end
