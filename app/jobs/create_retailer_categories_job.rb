# frozen_string_literal: true

class CreateRetailerCategoriesJob < ApplicationJob
  queue_as :default

  def perform(site_id = nil)
    # Retrieve all RetailerProductPriceMetric objects
    site_ids = site_id.nil? ? Site.pluck(:id) : [site_id]
    retailer_product_price_metrics = RetailerProductPriceMetric.where(
      site_ids: site_ids
    ).select(:category_name).distinct(:category_name)

    # Iterate over each RetailerProductPriceMetric object
    retailer_product_price_metrics.each do |metric|
      # Generate a new RetailerCategory object based on the metric
      RetailerCategory.create(name: metric.category_name, site_id: metric.site_id)
    end
  end
end
