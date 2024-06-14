# frozen_string_literal: true

module SearchBar
  extend ActiveSupport::Concern

  included do
    before_action :set_brands_for_selection
    before_action :set_categories_for_selection
    before_action :set_units_for_selection
  end

  def set_brands_for_selection
    establish_shard_connection do
      @brands_for_selection = Brand.where(id: Product.pluck(:brand_id)).order(:name)
    end
  end

  def set_categories_for_selection
    establish_shard_connection do
      @categories_for_selection = Category.where(id: Product.pluck(:category_id)).order(:name)
    end
  end

  def set_units_for_selection
    establish_shard_connection do
      @units_for_selection = Product.all.order(:measurement_unit).pluck(:measurement_unit).uniq.compact
    end
  end
end
