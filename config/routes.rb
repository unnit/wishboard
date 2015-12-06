Rails.application.routes.draw do

  get "users/sign_in" => "home#index"

  namespace :admin do
    root 'users#index'
    resources :users, only: [:index, :update] do
      member do
        post :lock
        post :unlock
      end
    end
    resources :categories, only: [:index, :create, :update, :destroy]
    resources :products, only: [:index] do
      member do
        get :toggle
        post :set_featured
      end
    end
    resources :transactions, only: [:index]
  end

  devise_for :users, :controllers => {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'omniauth_callbacks',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }
  # The priority is based upon order of creation: first created -> highest priority.

  resources :products, only: [:new, :edit, :create, :update] do
    collection do
      get :sub_categories
      get :index
      get :search
      post :update_available
      get :get_price
    end
    member do
      post :review
      post :rate
      post :remove_image
    end
  end

  resources :profiles, only: [:create, :update] do
    collection do
      get "dashboard"
    end
  end

  get :invitations, to: "invitations#index", as: :invitations
  post "invitations/send_email", to: "invitations#send_email", as: :send_email_invitations

  get :settings, to: "settings#index"
  get :about, to: "home#about"
  get "home/get_state_and_city", to: "home#get_state_and_city"

  resources :messages, only: [:destroy, :index, :show] do
    member do
      post :reply
    end
  end

  resources :transactions, only: [:new, :create, :update] do
    member do
      post :accept
      post :deny
      post :check_status_and_save_address_of_transaction
      get :checkout
      delete :delete_non_coco
    end
    collection do
      get :thankyou
      post :callback
    end
  end

  post "product/:id/checkout", to: "transactions#new", as: :product_checkout
  post "product/:id/non_coco", to: "transactions#non_coco", as: :non_coco_transaction
  #get "/products/:category", to: "products#index", as: :category
  get "/listings/:id", to: "products#show", as: :user_product

  root 'home#index'
end
