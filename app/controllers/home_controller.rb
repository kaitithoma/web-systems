class HomeController < ApplicationController
  include SearchBar

  def index
    establish_shard_connection do
      @categories = Category.all.map do |category|
        { id: category.id, name: category.name, products_size: category.products_size }
      end
    end
  end
end
