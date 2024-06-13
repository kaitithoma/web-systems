# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :init_filters, only: %i[index]

  def index
    @per = 50
    @page = params[:page] || 1
    retailer_products = RetailerProduct.where(
      'EXISTS (SELECT 1 FROM product_price_metrics where retailer_product_id = retailer_products.id)'
    )
    @products = Product.where(id: retailer_products.pluck(:product_id).uniq)
    @products = @products.search_text(params[:q]) if params[:q].present?
    @products = @products.where(category: @category_id) if @category_id.present?
    @products = @products.where(brand: @brand_id) if @brand_id.present?
    @products = @products.where(measurement_unit: @measurement_unit) if @measurement_unit.present?
    @products = @products.where.not(bundle: nil) if @bundled
    @products = @products.where(bundle: nil) if params[:bundled].present? && !@bundled
    @products = @products.order(:name)
    @products = @products.page(@page).per(@per)
  end

  def show
    @product = Product.find(params[:id])
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def price_history_diagram
    @product = Product.find(params[:id])
    @price_history = @product.lowest_price_history
  end

  def price_history
    @product_name = Product.find(params[:id]).name
    retailer_products = RetailerProduct.where(product_id: params[:id])
    @labels = retailer_products.map { |rp| "#{rp.name.gsub('"', '').gsub("''", '')} - #{rp.site_name}" }
    @dates = ProductPriceMetric.where(retailer_product_id: retailer_products.ids)
                               .order(:date)
                               .pluck(:date)
                               .map { |date| date.strftime('%d/%m/%Y') }
                               .uniq
    @prices = retailer_products.map do |rp|
      @dates.map do |date|
        metric = ProductPriceMetric.find_by(retailer_product_id: rp.id, date: date)
        metric&.price || nil
      end
    end
    @datasets = @prices.map.with_index do |prices, index|
      color = "##{SecureRandom.hex(3)}"
      {
        label: @labels[index],
        data: prices.map { |price| price.to_f if price.present? },
        borderColor: color,
        backgroundColor: color,
        borderWidth: 1
      }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:measurement_units, :item_id, :filterable_attributes, :brand)
  end

  def init_filters
    @category_id = params[:category_id] if params[:category_id].present?
    @brand_id = params[:brand_id] if params[:brand_id].present?
    @measurement_unit = params[:measurement_unit] if params[:measurement_unit].present?
    @bundled = (params[:bundled] == 'true') if params[:bundled].present?
  end
end
