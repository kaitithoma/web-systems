# frozen_string_literal: true

class MatchBrandsJob < ApplicationJob
  require 'damerau-levenshtein'
  require './app/services/jobs/tools'
  require 'pry'

  queue_as :default

  def perform(site_id = nil)
    sites = site_id.nil? ? Site.all : Site.where(id: site_id)
    sites.each do |site|
      site.retailer_brands.where(brand_id: nil).each do |brand|
        brand_name = compared_name(brand.name)
        other_brands = RetailerBrand.where.not(site_id: site.id)
        other_brands.each do |other_brand|
          other_brand_name = compared_name(other_brand.name)

          # binding.pry if brand.id == 1398 && other_brand.id == 4480

          next unless matched(brand_name, other_brand_name)

          if (matched_brand = Brand.where(
            "aliases && '{\"#{brand.name.upcase.gsub("'", "''").gsub('\\', '').gsub('"', '\\"')}\", "\
            "\"#{other_brand.name.upcase.gsub("'", "''").gsub('\\', '').gsub('"', '\\"')}\"}'"
          )&.first).nil?
            matched_brand = Brand.create(
              name: brand_name,
              aliases: [brand_name, other_brand_name].uniq
            )
          else
            matched_brand.update(aliases: (matched_brand.aliases + [brand_name, other_brand_name]).uniq)
          end
          brand.update(brand_id: matched_brand.id)
          other_brand.update(brand_id: matched_brand.id)
        end
      end
    end
  end

  private

  def compared_name(name)
    name = Jobs::Tools.remove_greek_accents(name.upcase)
                      .gsub(/[^a-zA-Z0-9ά-ωΑ-ώ\s]/, ' ')
                      .strip
    name.gsub(/\s{2,}/, '')
  end

  def matched(comparing_brand_name, comparing_other_brand_name)
    if comparing_brand_name.size > comparing_other_brand_name.size
      smallest_name = comparing_other_brand_name
      largest_name = comparing_brand_name
    else
      smallest_name = comparing_brand_name
      largest_name = comparing_other_brand_name
    end

    smallest_name.split.all? do |word|
      largest_name.split.any? do |nested_word|
        avg_word_size = (word.size + nested_word.size).to_f / 2
        (DamerauLevenshtein.distance(word, nested_word) / avg_word_size) <= 0.2
      end
    end
  end
end
