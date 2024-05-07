# frozen_string_literal: true

class ConnectRetailerProductsWithRetailerBrandsJob < ApplicationJob
  require './app/services/jobs/tools'

  queue_as :default

  def perform(site_id)
    site = Site.find(site_id)
    site.retailer_products.each do |product|
      product_name = Jobs::Tools.remove_greek_accents(product.name.upcase)
      RetailerBrand.where(site_id: site.id).each do |brand|
        brand_name = Jobs::Tools.remove_greek_accents(brand.name.upcase)
        if product_name.include?(brand_name) &&
           (product.retailer_brand_id.nil? || product.retailer_brand_name.size < brand.name.size)
          product.update(retailer_brand_id: brand.id)
        end
      end
    end
  end
end
