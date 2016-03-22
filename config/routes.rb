Rails.application.routes.draw do

  namespace :admin do
    root 'users#index'
    resources :users, only: [:index, :update] do
      collection do
        get :messages
        post :send_message
      end
      member do
        post :lock
        post :unlock
      end
    end
    resources :categories, only: [:index, :create, :update, :destroy]
    resources :products, only: [:index] do
      member do
        get :toggle
        get :toggle_currently_available
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
      get :all
    end
    member do
      post :update_admin_approved
      post :review
      post :rate
      post :remove_image
    end
  end

  resources :profiles, only: [:create, :update] do
    collection do
      post "update_business"
    end
  end

  get :invitations, to: "invitations#index", as: :invitations
  post "invitations/send_email", to: "invitations#send_email", as: :send_email_invitations

  get :settings, to: "settings#index"
  get :about, to: "home#about"
  get :terms, to: "home#terms"
  get :privacy, to: "home#privacy"
  get :contact, to: "home#contact"
  get "goodness-and-open-source", to: "home#goodness-and-open-source"
  get :sitemap, to: "home#sitemap"
  get "home/get_state_and_city", to: "home#get_state_and_city"
  get "user_signup_confirmation", to: "home#user_signup_confirmation"
  get "settings/business", to: "profiles#business_profile"
  get "dashboard", to: "profiles#dashboard"
  get "signup", to: "home#sign_up"
  get "login", to: "home#login"
  post :bulk_bookings, to: "home#bulk_bookings"
  get "offers", to: "home#offers"
  get "feed", to: "home#feed"
  post "toggle_follow/:id", to: "home#toggle_follow", as: :user_toggle_follow
  get ":id", to: "home#myprofile", as: :myprofile
  get ":id/showpieces", to: "home#myshowpieces", as: :myshowpieces
  get ":id/wishes", to: "home#mywishes", as: :mywishes
  get ":id/following", to: "home#following", as: :following
  get ":id/followers", to: "home#followers", as: :followers
  get "user_card/:id", to: "home#user_card", as: :get_user_card

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

  resources :showcases, only: [:edit, :create, :update, :destroy, :show] do
    member do
      post :wow
      post :comment
      post :edit_comment
      delete :delete_comment
    end
  end

  post "product/:id/checkout", to: "transactions#new", as: :product_checkout
  post "product/:id/non_coco", to: "transactions#non_coco", as: :non_coco_transaction
  get "/categories/:id", to: "products#category", as: :category
  get "/listings/:id", to: "products#show", as: :user_product

  root 'home#index'
end
