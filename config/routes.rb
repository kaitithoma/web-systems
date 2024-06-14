Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
   # Defines the root path route ("/")
  root 'home#index'

  get 'products/:id/price_history' => 'products#price_history', as: :products_price_history

  resources :sites, only: %i[show index edit update] do
    member do
      post 'fetch_data'
      post 'fetch_brands'
      post 'add_categories'
      post 'add_products'
      post 'add_price_metrics'
      post 'connect_retailer_products_with_retailer_brands'
      post 'match_brands'
      post 'match_products'
      post 'connect_products_with_categories'
    end
  end

  resources :products, only: %i[index show]
  resources :brands, only: [] do
    collection do
      get 'autocomplete'
    end
  end
end
