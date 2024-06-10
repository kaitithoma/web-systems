# frozen_string_literal: true

# This class finds all category hyperlinks and fetches all brands from each category page
# It then imports the retailer brands into the database
# Note: Getting brands from the main search page would only get a fraction of the brands
class FetchMyMarketBrandsJob < ApplicationJob
  require 'nokogiri'
  require 'open-uri'
  require 'pry'
  require 'activerecord-import'

  queue_as :default

  def perform(*_args)
    @site = Site.find_by(name: 'My Market')
    @url = @site.url
    RetailerBrand.import(brands_set.to_a, on_duplicate_key_ignore: true)
  end

  private

  def category_links
    doc = Nokogiri::HTML(URI.open(@url))
    links = doc.xpath('/html/body/div[1]/main/div[3]/aside/div[2]/div/div[2]/div[1]/div[1]/div[2]/div[2]/ul/li/a/@href')
    links.map(&:value)
  end

  def brand_xpath
    '/html/body/div[1]/main/div[3]/aside/div[2]/div/div[2]/div[1]/div[1]/div[3]/div[2]/ul/li/a/span[2]'
  end

  def brands_set
    array = []
    category_links.each do |link|
      doc = Nokogiri::HTML(URI.open("#{@url.gsub('/search', '')}#{link}"))
      return array if doc.nil?

      array << doc.xpath(brand_xpath).map do |brand|
        {
          name: brand.text.encode('iso-8859-1').force_encoding('utf-8')&.strip,
          site_id: @site.id
        }
      end
    end
    array.flatten
  rescue OpenURI::HTTPError => e
    puts "Error: #{e.message}"
    array.flatten
  end
end
