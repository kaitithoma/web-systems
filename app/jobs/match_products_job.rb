# frozen_string_literal: true

class MatchProductsJob < ActiveJob::Base
  require 'damerau-levenshtein'
  require './app/services/jobs/tools'

  queue_as :default

  # This job should run for the site with the most products
  def perform(site_id)
    @site = Site.find(site_id)

    site.retailer_products.where(retailer_brand_id: RetailerBrand.where.not(brand_id: nil)).each do |product|
      # product_name = product.name.upcase
      other_products = other_products(product)
      next if other_products.blank?

      other_products.each do |other_product|
        # other_product_name = other_product.name.upcase
        comparing_product_name = comparing_product_name(product)
        comparing_other_product_name = comparing_product_name(other_product)
        # distance = DamerauLevenshtein.distance(comparing_product_name, comparing_other_product_name)
        # next unless distance.zero?

        unless (comparing_product_name.split & comparing_other_product_name.split).size ==
               ([comparing_product_name.split.size, comparing_other_product_name.split.size].min)
          next
        end
        matched_product = Product.where(brand_id: product.retailer_brand.brand_id).where(
          "aliases && '{\"#{product.name.upcase.gsub("'", "''").gsub('"', '\\"').gsub('"', '\\"')}\", "\
          "\"#{other_product.name.upcase.gsub("'", "''").gsub('\\', '').gsub('"', '\\"')}\"}'"
        )&.first
        if matched_product.nil?
          matched_product = Product.create(
            name: product.name.upcase,
            aliases: [product.name.upcase, other_product.name.upcase].uniq,
            brand_id: product.retailer_brand.brand_id,
            quantity: product.quantity,
            measurement_unit: product.measurement_unit,
            bundle: product.bundle
          )
        else
          matched_product.update(
            aliases: (matched_product.aliases + [product.name.upcase, other_product.name.upcase]).uniq
          )
        end
        product.update(product_id: matched_product.id)
        other_product.update(product_id: matched_product.id)
      end
    end
  end

  private

  attr_reader :site

  def products
    @products ||= site.retailer_products
  end

  def other_products(product)
    results = RetailerProduct.where.not(id: product.id)
                             .where.not(site_id: product.site_id)
                             .where(retailer_brand_id: product.retailer_brand.brand.retailer_brand_ids)
    results = results.where(quantity: product.quantity) unless product.quantity.nil?
    results = results.where(measurement_unit: product.measurement_unit) unless product.measurement_unit.nil?
    results = results.where(bundle: product.bundle) unless product.bundle.nil?
    results
  end

  def product_name(product)
    product.name.upcase
  end

  def comparing_product_name(product)
    name = Jobs::Tools.remove_greek_accents(product.name.upcase)
                      .gsub(/#{Jobs::Tools::MEASUREMENT_UNIT[product.measurement_unit]&.join('|')}/, '')
                      .gsub(/[^a-zA-Z0-9ά-ωΑ-ώ\s]/, '')
                      .gsub(/\d/, '')
                      .gsub(/\s{2,}/, '')
                      .strip
    return name unless product.retailer_brand&.brand

    name.gsub(product.retailer_brand.brand.name, '')
  end
end
