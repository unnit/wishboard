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
    omniauth_callbacks: 'omniauth_callbacks'
  }
  # The priority is based upon order of creation: first created -> highest priority.

  resources :products, only: [:new, :edit, :create, :update] do
    collection do
      get :sub_categories
      get :search
      post :search
      post :update_available
    end
    member do
      post :review
      post :rate
    end
  end
  
  resources :profiles, only: [:create, :update] do 
    collection do
      get "my-profile"
    end
  end

  resources :images, only: [:create]

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
      get :checkout
    end
    collection do
      get :get_price
      get :thankyou
      post :callback
    end
  end

  post "product/:product_id/checkout", to: "transactions#new", as: :product_checkout
  get "/products/:category", to: "products#index", as: :category
  get "/:profile_id/:id", to: "products#show", as: :user_product
  
  root 'home#index'
end