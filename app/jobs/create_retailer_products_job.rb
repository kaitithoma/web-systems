# frozen_string_literal: true

class CreateRetailerProductsJob < ApplicationJob
  require './app/services/jobs/tools'

  queue_as :default

  def perform(args = {})
    @site_ids = args[:site_id].nil? ? Site.pluck(:id) : [args[:site_id]]
    @country = args[:country]
    establish_shard_connection(country) do
      RetailerProduct.import(
        unique_products, validate: false,
                        on_duplicate_key_update: {
                          conflict_target: %i[name site_id],
                          columns: %i[measurement_unit quantity bundle url retailer_category_id]
                        }
      )
    end
  end

  private

  attr_reader :site_ids, :country

  def measurement_unit(name)
    Jobs::Tools.get_alias_for_unit_measurement(name)
  end

  def measurement_unit_string(measurement_unit, prefix: false)
    result = Jobs::Tools::MEASUREMENT_UNIT[measurement_unit]&.join('|')
    return result unless prefix

    "|#{result}"
  end

  def quantity(name, measurement_unit)
    return unless measurement_unit

    result = name.match(
      /((?<!\+)(\d+(\s*)(x|X|,|\.)*(\s*))*\d+)(?=(?:(\s*)(#{measurement_unit_string(measurement_unit)}))(?!\+))/
    )
    return if result.nil?

    result[0].gsub('(', '').gsub(')', '')
  end

  def bundle(name, measurement_unit)
    result = name.match(
      /((\()*(\d*)(%#{measurement_unit_string(measurement_unit, prefix: true)})*)(\)*)(\s*)\+(\s*)\d+/
    )
    return if result.nil?

    result[0].gsub('(', '').gsub(')', '')
  end

  def retailer_products
    # Retrieve all RetailerProductPriceMetric objects
    retailer_product_price_metrics = RetailerProductPriceMetric.where(
      site_id: site_ids
    ).where.not(url: nil).select(:product_name, :url, :category_name, :site_id)#.distinct(:product_name)
    retailer_product_price_metrics.map do |metric|
      name = Jobs::Tools.remove_greek_accents(metric.product_name.upcase)
      measurement_unit = measurement_unit(name)
      {
        name: metric.product_name,
        site_id: metric.site_id,
        measurement_unit: measurement_unit,
        quantity: quantity(name, measurement_unit),
        bundle: bundle(name, measurement_unit),
        url: metric.url,
        retailer_category_id: RetailerCategory.find_or_create_by(
          name: metric.category_name, site_id: metric.site_id
        ).id
      }
    end
  end

  def unique_products
    retailer_products.to_a.uniq do |item|
      %i[name site_id].map { |field| item[field] }.join(':')
    end
  end
end
