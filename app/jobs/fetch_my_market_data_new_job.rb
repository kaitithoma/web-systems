# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'activerecord-import'
require 'uri'
require 'selenium-webdriver'

# NOTE: The categories are not being fetched correctly. The categories are being fetched from the URL instead of the category name.
# They are fixed manually using this hash:
=begin
  UNI_CATEGORIES = {
    "https://www.mymarket.gr/frouta-lachanika"=>"Φρούτα & Λαχανικά",
    "https://www.mymarket.gr/fresko-kreas-psari"=>"Φρέσκο Κρέας & Ψάρι",
    "https://www.mymarket.gr/galaktokomika-eidi-psygeiou"=>"Γαλακτοκομικά & Είδη Ψυγείου",
    "https://www.mymarket.gr/tyria-allantika-deli"=>"Τυριά, Αλλαντικά & Deli",
    "https://www.mymarket.gr/katepsygmena-trofima"=>"Κατεψυγμένα Τρόφιμα",
    "https://www.mymarket.gr/mpyres-anapsyktika-krasia-pota"=>"Μπύρες, Αναψυκτικά, Κρασιά & Ποτά",
    "https://www.mymarket.gr/proino-rofimata-kafes"=>"Πρωινό, Ροφήματα & Καφές",
    "https://www.mymarket.gr/artozacharoplasteio-snacks"=>"Αρτοζαχαροπλαστείο & Snacks",
    "https://www.mymarket.gr/trofima"=>"Τρόφιμα",
    "https://www.mymarket.gr/frontida-gia-to-moro-sas"=>"Φροντίδα για το Μωρό σας",
    "https://www.mymarket.gr/prosopiki-frontida"=>"Προσωπική Φροντίδα",
    "https://www.mymarket.gr/oikiaki-frontida-chartika"=>"Οικιακή Φροντίδα & Χαρτικά",
    "https://www.mymarket.gr/kouzina-mikrosyskeves-spiti"=>"Κουζίνα, Μικροσυσκευές & Σπίτι",
    "https://www.mymarket.gr/frontida-gia-to-katoikidio-sas"=>"Φροντίδα για το Κατοικίδιο σας",
    "https://www.mymarket.gr/epochiaka"=>"Εποχιακά"
  }
=end

class FetchMyMarketDataNewJob < ApplicationJob
  queue_as :default

  def perform(args = {})
    # Fetch products using Nokogiri
    @site = Site.find_by(name: 'My Market')
    @url = @site.url
    @country = args[:country]

    establish_shard_connection(country) do

      RetailerProductPriceMetric.import(
        unique_items, on_duplicate_key_update: {
          conflict_target: %i[site_id product_name date], columns: %i[price_data category_name url]
        }
      )
    end
  end

  private

  attr_reader :country

  def category_links
    # Initialize a Selenium WebDriver instance
    driver = Selenium::WebDriver.for :chrome
    wait = Selenium::WebDriver::Wait.new(timeout: 10)

    # Navigate to a webpage
    driver.get(@url)

    driver.manage.window.resize_to(1000, 1000)

    # Find the element you want to hover over
    element = wait.until { driver.find_element(:xpath, '//*[@id="CybotCookiebotDialogBodyButtonDecline"]') }
    element.click

    element = driver.find_element(:xpath, '/html/body/header/div[2]/div/div[2]/button')
    element.click

    (5..19).map do |i|
      {
        category_url: wait.until { driver.find_element(:xpath, "/html/body/div[5]/div/div/nav/div/ul/li[#{i}]/a").attribute('href') },
        category_name: wait.until { driver.find_element(:xpath, "/html/body/div[5]/div/div/nav/div/ul/li[#{i}]/a").attribute('text').strip }
      }
    end
  end

  def price_data(product)
    result = product.css('.measure-label-wrapper').each_with_object({}) do |label, hash|
      hash[
        label.css('[class="text-[6px] leading-[6px] sm:text-[7px] leading-[7px]"]').text.encode('iso-8859-1').force_encoding('utf-8')&.strip
      ] = label.css('.font-semibold').text.encode('iso-8859-1').force_encoding('utf-8')&.strip
    end
    return result if (result.keys & ['Τελική τιμή', 'Τελική τιμή σετ']).any?

    result['Τελική τιμή'] = product.css('.price').text.encode('iso-8859-1').force_encoding('utf-8').strip
    result
  end

  def product_hash(product, category_name)
    {
      product_name: product.css('h3').text.encode('iso-8859-1').force_encoding('utf-8')&.strip,
      retailer_id: product.css('.sku').text.encode('iso-8859-1').force_encoding('utf-8')[/\d+/]&.strip,
      price_data: price_data(product),
      category_name: category_name,
      date: Date.today,
      site_id: @site.id,
      url: product.css('a').first['href']
    }
  end

  def iterate_pages(page, hash)
    doc = Nokogiri::HTML(URI.open("#{hash[:category_url]}?page=#{page}"))
    @array += doc.css('article').map do |product|
      product_hash(product, hash[:category_name])
    end
    page += 1
    iterate_pages(page, hash)
  rescue OpenURI::HTTPError => e
    puts "Error: #{e.message}"
  end

  def fill_array
    @array = []
    category_links.each do |hash|
      page = 1
      iterate_pages(page, hash)
    end
  rescue OpenURI::HTTPError => e
    puts "Error: #{e.message}"
  end

  def unique_items
    fill_array
    @array.uniq do |item|
      %i[site_id product_name date].map { |field| item[field] }.join(':')
    end
  end
end
