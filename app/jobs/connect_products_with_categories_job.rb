# frozen_string_literal: true

class ConnectProductsWithCategoriesJob < ApplicationJob
  queue_as :default

  def perform(site_id = nil)
    @site_ids = site_id.nil? ? Site.pluck(:id) : [site_id]
    connect
  end

  private

  attr_reader :site_ids

  def exists
    "EXISTS (
      SELECT 1 FROM retailer_products
      WHERE product_id = products.id
      AND retailer_products.site_id IN (#{site_ids.join(',')}))"
  end

  def connect
    Product.where(category_id: nil)
           .where(exists)
           .in_batches.each do |products|
      products.each do |product|
        retailer_product = product.retailer_products.where.not(retailer_category: nil).first
        next if retailer_product.nil?

        retailer_category = retailer_product.retailer_category
        next if retailer_category.nil?

        category = retailer_category.category
        product.update(category: category)
      end
    end
  end
end
