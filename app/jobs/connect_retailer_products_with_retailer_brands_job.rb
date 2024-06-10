# frozen_string_literal: true

class ConnectRetailerProductsWithRetailerBrandsJob < ApplicationJob
  require './app/services/jobs/tools'

  queue_as :default

  def perform(site_id = nil)
    sites = site_id.nil? ? Site.all : Site.where(id: site_id)
    sites.each do |site|
      site.retailer_products.where(retailer_brand_id: nil).each do |product|
        product_name = Jobs::Tools.remove_greek_accents(product.name.upcase)
        RetailerBrand.where(site_id: site.id).each do |brand|
          brand_name = Jobs::Tools.remove_greek_accents(brand.name.upcase)
          brand_name_words_num = brand_name.split(' ').size
          product_name.split(' ').each_cons(brand_name_words_num) do |words|
            next unless words.join(' ') == brand_name

            product.update(retailer_brand_id: brand.id)
            break
          end
        end
      end
    end
  end
end
