# frozen_string_literal: true

class SitesController < ApplicationController
  def index
    @sites = Site.all
  end

  def show
    @site = Site.find(params[:id])
  end

  def new
    @site = Site.new
  end

  def edit
    @site = Site.find(params[:id])
  end

  def update
    @site = Site.find(params[:id])
    if @site.update(site_params)
      redirect_to @site
    else
      render :edit
    end
  end

  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    redirect_to sites_path
  end

  def fetch_data
    site = Site.find(params[:id])
    site.fetch_data_job.safe_constantize.perform_later
    flash[:notice] = 'Job is being performed.'
  end

  def fetch_brands
    site = Site.find(params[:id])
    site.fetch_brands_job.safe_constantize.perform_later
    flash[:notice] = 'Job is being performed.'
  end

  def add_categories
    CreateRetailerCategoriesJob.perform_later(params[:id])
    flash[:notice] = 'Job is being performed.'
  end

  def add_products
    CreateRetailerProductsJob.perform_later(params[:id])
    flash[:notice] = 'Job is being performed.'
  end

  def add_price_metrics
    CreateProductPriceMetricsJob.perform_later(params[:id])
    flash[:notice] = 'Job is being performed.'
  end

  def connect_retailer_products_with_retailer_brands
    ConnectRetailerProductsWithRetailerBrandsJob.perform_later(params[:id])
    flash[:notice] = 'Job is being performed.'
  end

  def match_brands
    MatchBrandsJob.perform_later(params[:id])
    flash[:notice] = 'Job is being performed.'
  end

  def match_products
    MatchProductsJob.perform_later(params[:id])
    flash[:notice] = 'Job is being performed.'
  end

  def connect_products_wiht_categories
    ConnectProductsWithCategoriesJob.perform_later(params[:id])
    flash[:notice] = 'Job is being performed.'
  end

  private

  def site_params
    params.require(:site).permit(:name, :url)
  end
end
