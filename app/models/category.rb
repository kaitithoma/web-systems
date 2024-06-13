# frozen_string_literal: true

class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :retailer_categories

  def products_size
    Rails.cache.fetch("#{cache_key}/#{__method__}", expires_in: 1.minute) do
      Product.where(category: self).size
    end
  end
end
