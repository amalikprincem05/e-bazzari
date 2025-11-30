Rails.application.routes.draw do
  devise_for :users
  root 'home#index'
  
  get 'home', to: 'home#index'
  get 'shop', to: 'products#index'
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'
  
  resources :products, only: [:index, :show]
  resources :cart_items, only: [:create, :update, :destroy]
  resources :orders, only: [:index, :show, :create] do
    collection do
      get :debug
    end
  end
  
  get 'cart', to: 'carts#show'
  delete 'cart', to: 'carts#destroy'
  
  # Admin routes
  get 'admin/dashboard', to: 'admin#dashboard', as: 'admin_dashboard'
  get 'admin/products', to: 'admin#products', as: 'admin_products'
  get 'admin/products/new', to: 'admin#new_product', as: 'admin_new_product'
  post 'admin/products', to: 'admin#create_product', as: 'admin_create_product'
  get 'admin/products/:id/edit', to: 'admin#edit_product', as: 'admin_edit_product'
  patch 'admin/products/:id', to: 'admin#update_product', as: 'admin_update_product'
  delete 'admin/products/:id', to: 'admin#delete_product', as: 'admin_delete_product'
  get 'admin/orders', to: 'admin#orders', as: 'admin_orders'
  patch 'admin/orders/:id/status', to: 'admin#update_order_status', as: 'admin_update_order_status'
  get 'admin/users', to: 'admin#users', as: 'admin_users'
  post 'admin/users', to: 'admin#create_user', as: 'admin_create_user'

  namespace :super_admin do
    get 'dashboard', to: 'dashboard#index'
    resources :users, only: [] do
      collection do
        post :create_admin
      end

      member do
        patch :promote_to_admin
        patch :demote_to_user
      end
    end
  end

  # Stripe checkout and webhooks
  post 'stripe/checkout', to: 'stripe#create_checkout_session'
  post 'stripe/webhook', to: 'stripe#webhook'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
