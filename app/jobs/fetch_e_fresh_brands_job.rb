# frozen_string_literal: true

# This class finds all category hyperlinks and fetches all brands from each category page
# It then imports the retailer brands into the database
# Note: Getting brands from the main search page would only get a fraction of the brands
class FetchEFreshBrandsJob < ApplicationJob
  require 'nokogiri'
  require 'open-uri'
  require 'pry'
  require 'activerecord-import'

  queue_as :default

  def perform(*_args)
    # Fetch brands using Nokogiri
    @site = Site.find_by(name: 'E-Fresh')
    @url = @site.url
    RetailerBrand.import(brands_set.to_a, on_duplicate_key_ignore: true)
    # 1206 (unique) brands imported
  end

  private

  def category_links
    Nokogiri::HTML(URI.open(@url.to_s)).css('#nav-menu').css('.level-1').css('a').map do |row|
      row.attribute('data-href')&.value
    end.compact
  end

  def brand_xpath(index)
    "/html/body/div[1]/div[5]/div/div/div/div[1]/div/div/div/div[#{index}]/div/ol/li[2]/div/label/text()"
  end

  def brands_set
    array = []
    category_links.each do |link|
      html_content = URI.open(link.to_s).read.gsub(/\\u([\da-fA-F]{4})/) { $1.hex.chr(Encoding::UTF_8) }
      doc = Nokogiri::HTML(html_content)
      return array if doc.nil?

      js_code = doc.xpath("//script[contains(text(), 'food_brand')]")[0].content
      # Match only whichever is between "title" and ","link":"efreshgr:\/\/list\/\?"
      # Match whatever is not followed by ","link":"efreshgr:\/\/category\/\?
      regex = /(?:food_brand=\d+","app":\[{"title":")(.*?)(?!","link":"efreshgr:\\\/\\\/category\\\/\?)(?=(?:","link":"efreshgr:\\\/\\\/list\\\/\?))/ # FINAL REGEX OMGOMGOMG
      brand_names = js_code.scan(regex).flatten

      # binding.pry

      array << brand_names.map do |name|
        { name: name, site_id: @site.id }
      end
    end
    array.flatten
  rescue OpenURI::HTTPError => e
    puts "Error: #{e.message}"
    array.flatten
  end
end
