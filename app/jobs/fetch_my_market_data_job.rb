# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
#require 'byebug'
require 'pry'
require 'activerecord-import'
require 'uri'

class FetchMyMarketDataJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # Fetch products using Nokogiri
    @site = Site.find_by(name: 'My Market')
    @url = @site.url
    fill_array
    RetailerProductPriceMetric.import(
      @array,
      on_duplicate_key_update: {
        conflict_target: %i[site_id product_name date],
        columns: %i[price_data category_name url]
      }
    )
  end

  private

  def category_links
    doc = Nokogiri::HTML(URI.open(@url))
    links = doc.xpath('/html/body/div[1]/main/div[3]/aside/div[2]/div/div[2]/div[1]/div[1]/div[2]/div[2]/ul/li/a/@href')
    links.map(&:value)
  end

  def price_data(product)
    product.css('.measure-label-wrapper').each_with_object({}) do |label, hash|
      hash[
        label.css('[class="text-[7px]"]').text.encode('iso-8859-1').force_encoding('utf-8')&.strip
      ] = label.css('.font-bold').text.encode('iso-8859-1').force_encoding('utf-8')&.strip
    end
  end

  def product_hash(product, link)
    {
      product_name: product.css('h3').text.encode('iso-8859-1').force_encoding('utf-8')&.strip,
      retailer_id: product.css('.teaser-sku').text.encode('iso-8859-1').force_encoding('utf-8')[/\d+/]&.strip,
      price_data: price_data(product),
      category_name: CGI.unescape(link).gsub('/search?categories=', '').strip,
      date: Date.today,
      site_id: @site.id,
      # url: @url
    }
  end

  def iterate_pages(page, link)
    doc = Nokogiri::HTML(URI.open("#{@url.gsub('/search', '')}#{link}&page=#{page}"))
    @array += doc.css('article').map do |product|
      product_hash(product, link)
    end
    page += 1
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
