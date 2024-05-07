# frozen_string_literal: true

class CreateRetailerCategoriesJob < ActiveJob::Base
  queue_as :default

  def perform(site_id)
    # Retrieve all RetailerProductPriceMetric objects
    retailer_product_price_metrics = RetailerProductPriceMetric.where(
      site_id: site_id
    ).select(:category_name).distinct(:category_name)

    # Iterate over each RetailerProductPriceMetric object
    retailer_product_price_metrics.each do |metric|
      # Generate a new RetailerCategory object based on the metric
      RetailerCategory.create(name: metric.category_name, site_id: site_id)
    end
  end
end
