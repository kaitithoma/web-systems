# frozen_string_literal: true

class BrandsController < ApplicationController
  def autocomplete
    if params[:query].present?
      @brands = Brand.where("name LIKE ?", "%#{params[:query]}%")
    else
      @brands = Brand.none
    end

    render json: @brands.map { |brand| { id: brand.id, name: brand.name } }
  end
end
