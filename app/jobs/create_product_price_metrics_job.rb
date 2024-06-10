# frozen_string_literal: true

class CreateProductPriceMetricsJob < ApplicationJob
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

  def perform(site_id = nil)
    @sites = site_id.nil? ? Site.all : Site.where(id: site_id)
    ProductPriceMetric.import(
      product_price_metrics,
      on_duplicate_key_update: {
        conflict_target: %i[retailer_product_id date],
        columns: %i[price measurement_unit_price old_price old_measurement_unit_price url]
      }
    )
  end

  private

  attr_reader :sites, :url

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

  def product_price_metrics
    sites.flat_map do |site|
      products = site.retailer_products
      RetailerProductPriceMetric.where(site_id: site.id).map do |retailer_product_price_metric|
        mup = price(retailer_product_price_metric, 'final_price_per_unit')
        {
          price: price(retailer_product_price_metric, 'final_price') || mup,
          measurement_unit_price: mup,
          old_price: price(retailer_product_price_metric, 'old_price'),
          old_measurement_unit_price: price(retailer_product_price_metric, 'old_price_per_unit'),
          retailer_product_id: products.where(name: retailer_product_price_metric.product_name).first&.id,
          date: retailer_product_price_metric.date,
          url: retailer_product_price_metric.url
        }
      end
    end
  end
end
