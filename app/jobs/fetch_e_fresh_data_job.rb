# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
#require 'byebug'
require 'pry'

class FetchEFreshDataJob < ApplicationJob
  queue_as :default

  def perform
    # Fetch products using Nokogiri
    @site = Site.find_by(name: 'E-Fresh')
    @url = @site.url
    fill_array
    RetailerProductPriceMetric.import(@array, on_duplicate_key_ignore: true)
  end

  private

  def category_links
    Nokogiri::HTML(URI.open(@url.to_s)).css('#nav-menu').css('.level-1').css('a').map do |row|
      row.attribute('data-href')&.value
    end.compact
  end

  def product_regex
    /(?:"kodikos":"\d+","title":")(.*?)(?!","commnet":")(?=(?:","slug":"))/
  end

  def retailer_id_regex
    /(?:"kodikos":")(.*?)(?=(?:","title":"))/
  end

  def category_name_regex
    /(?:,"category_base_name":")(.*?)(?=(?:","category_base_id"))/
  end

  def final_price_regex
    /(?:"slug":"\S*","price":)(.*?)(?=(?:,"offer"))/
  end

  # NOTE: when old price is 0 maybe we should omit it when adding it to hash
  def old_price_regex
    /(?:,"price_old":)(.*?)(?=(?:,"price_per_unit"))/
  end

  def price_per_unit_regex
    /(?:,"price_per_unit":)(.*?)(?=(?:,"price_old_per_unit":))/
  end

  def old_price_per_unit_regex
    /(?:,"price_old_per_unit":)(.*?)(?=(?:,"tax_rate":))/
  end

  def iterate_pages(page, link)
    html_content = URI.open("#{link}?page=#{page}&order=position").read.gsub(
      /\\u([\da-fA-F]{4})/
    ) { $1.hex.chr(Encoding::UTF_8) }

    doc = Nokogiri::HTML(html_content)
    product_names = doc.content.scan(product_regex).flatten

    return if product_names.empty?

    (0..(product_names.size - 1)).each do |index|
      @array << {
        product_name: product_names[index],
        retailer_id: doc.content.scan(retailer_id_regex).flatten[index],
        price_data: {
          'final_price' => doc.content.scan(final_price_regex).flatten[index],
          'old_price' => doc.content.scan(old_price_regex).flatten[index],
          'price_per_unit' => doc.content.scan(price_per_unit_regex).flatten[index],
          'old_price_per_unit' => doc.content.scan(old_price_per_unit_regex).flatten[index]
        },
        category_name: doc.content.scan(category_name_regex).flatten[index],
        date: Date.today,
        site_id: @site.id
      }
    end
    page += 1
    # puts page if page % 10 == 0
    iterate_pages(page, link)
  rescue OpenURI::HTTPError => e
    puts "Error: #{e.message}"
  end

  def fill_array
    @array = []

    category_links.each do |link|
      page = 1
      iterate_pages(page, link)
    end
  rescue OpenURI::HTTPError => e
    puts "Error: #{e.message}"
  end
end
