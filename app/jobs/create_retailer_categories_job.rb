# frozen_string_literal: true

class CreateRetailerCategoriesJob < ApplicationJob
  queue_as :default

  def perform(args)
    # Retrieve all RetailerProductPriceMetric objects
    site_ids = args[:site_id].nil? ? Site.pluck(:id) : args[:site_id]
    retailer_product_price_metrics = RetailerProductPriceMetric.where(
      "site_id IN (#{site_ids.join(',')})"
    ).select(:category_name, :site_id).distinct(:category_name)

    # Iterate over each RetailerProductPriceMetric object
    establish_shard_connection(args[:country]) do
      retailer_product_price_metrics.each do |metric|
        # Generate a new RetailerCategory object based on the metric
        RetailerCategory.create(name: metric.category_name, site_id: metric.site_id)
      end
    end
  end
end
