# frozen_string_literal: true

class RetailerBrand < ApplicationRecord
  has_many :retailer_products
  belongs_to :site
  belongs_to :brand, optional: true

  validates :name, presence: true, uniqueness: { scope: :site_id }
end
