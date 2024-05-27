Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'products/:id' => 'products#show'
  get 'search' => 'products#search', as: :search

  get 'products/:id/price_history' => 'products#price_history',
      as: :products_price_history

  get 'sites' => 'sites#index', as: :sites
  get 'sites/:id' => 'sites#show', as: :site
  patch 'sites/:id' => 'sites#update', as: 'edit_site'

  # Defines the root path route ("/")
  root 'products#index'

  resources :products, only: %i[index show update destroy]
end
