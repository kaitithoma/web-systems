# frozen_string_literal: true

class Site < ApplicationRecord
  has_many :retailer_products
  has_many :retailer_brands

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
end
