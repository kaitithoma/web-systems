# frozen_string_literal: true

class MatchBrandsJob < ActiveJob::Base
  require 'damerau-levenshtein'
  require './app/services/jobs/tools'

  queue_as :default

  def perform
    Site.all.each do |site|
      site.retailer_brands.each do |brand|
        brand_name = brand.name.upcase
        other_brands = RetailerBrand.where.not(site_id: site.id)
        other_brands.each do |other_brand|
          other_brand_name = other_brand.name.upcase
          comparing_brand_name = Jobs::Tools.remove_greek_accents(brand_name.gsub(/[^a-zA-Z0-9ΆΈ-ώ]/, ''))
          comparing_other_brand_name = Jobs::Tools.remove_greek_accents(other_brand_name.gsub(/[^a-zA-Z0-9ΆΈ-ώ]/, ''))
          distance = DamerauLevenshtein.distance(comparing_brand_name, comparing_other_brand_name)
          next unless distance.zero?

          if Brand.find_by(name: brand_name).nil?
            matched_brand = Brand.create(
              name: brand_name,
              aliases: [brand_name, other_brand_name].uniq
            )
          else
            matched_brand = Brand.find_by(name: brand_name)
            matched_brand.update(aliases: (matched_brand.aliases + [brand_name, other_brand_name]).uniq)
          end
          brand.update(brand_id: matched_brand.id)
          other_brand.update(brand_id: matched_brand.id)
        end
      end
    end
  end
end
