# frozen_string_literal: true

class CreateProductPriceMetricsJob < ActiveJob::Base
  queue_as :default

  UNIFORM_KEYS_HASH = {
    ['Αρχική τιμή', 'Αρχική τιμή σετ', 'old_price'] => 'old_price',
    ['Τελική τιμή', 'Τελική τιμή σετ', 'final_price'] => 'final_price',
    ['Αρχική Τιμή τεμαχίου',
     'Αρχική τιμή κιλού',
     'Αρχική τιμή λίτρου',
     'Αρχική τιμή φύλλου',
     'Αρχική τιμή μεζούρας',
     'Αρχική τιμή μέτρου',
     'Αρχική τιμή τ.μ.',
     'old_price_per_unit'] => 'old_price_per_unit',
    ['Τελική τιμή τεμαχίου',
     'Τελική τιμή κιλού',
     'Τελική τιμή λίτρου',
     'Τελική τιμή φύλλου',
     'Τελική τιμή μεζούρας',
     'Τελική τιμή μέτρου',
     'Τελική τιμή τ.μ.',
     'Τιμή κιλού',
     'Τιμή λίτρου',
     'Τιμή μεζούρας',
     'Τιμή τεμαχίου',
     'Τιμή φύλλου',
     'Τιμή μέτρου',
     'Τιμή ζεύγους',
     'Τιμή τ.μ.',
     'price_per_unit'] => 'final_price_per_unit'
  }.freeze

  def perform(site_id)
    @site = Site.find(site_id)
    ProductPriceMetric.import(product_price_metrics, on_duplicate_key_ignore: true)
  end

  private

  attr_reader :site, :url

  def price(rppm, type)
    if rppm.price_data.size == 1 && type == 'final_price'
      return rppm.price_data.detect { |_k, v| v.present? }
                 .last
                 .gsub(',', '.')
                 .match(/[+-]?([0-9]*[(.|,)])?[0-9]+/)[0].to_f.round(2)
    end

    price = rppm.price_data.detect do |key, _value|
      UNIFORM_KEYS_HASH.detect { |_k, v| v == type }[0].include?(key)
    end&.last&.gsub(',', '.')&.match(/[+-]?([0-9]*[.])?[0-9]+/)
    price[0].to_f.round(2) if price.present?
  end

  def products
    @products ||= site.retailer_products
  end

  def product_price_metrics
    RetailerProductPriceMetric.where(site_id: site.id).map do |retailer_product_price_metric|
      mup = price(retailer_product_price_metric, 'final_price_per_unit')
      {
        price: price(retailer_product_price_metric, 'final_price') || mup,
        measurement_unit_price: mup,
        old_price: price(retailer_product_price_metric, 'old_price'),
        old_measurement_unit_price: price(retailer_product_price_metric, 'old_price_per_unit'),
        retailer_product_id: products.find_by(name: retailer_product_price_metric.product_name)&.id,
        date: retailer_product_price_metric.date
      }
    end
  end
end
