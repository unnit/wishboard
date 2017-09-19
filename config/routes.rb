Rails.application.routes.draw do
  get 'home/display_preview'
  resources :cocotransfers,only: [:create, :new, :update] do
    member do
      get :checkout
      get :transfer_success
    end
    collection do
      post :callback
    end
  end

  mount ActionCable.server => '/cable'
  namespace :admin do
    get 'miscellaneous/no_of_emojis'
    get 'miscellaneous/index'
    get "users/admin_firebasenotifications", to: "users#admin_firebasenotifications", as: :admin_firebasenotifications
    post "users/send_new_firebase_notifications", to: "users#send_new_firebase_notification", as: :send_new_firebase_notifications
    root 'users#index'
    resources :cocotransfers, only: [:index]
    resources :users, only: [:index, :update] do
      collection do
        get :messages
        post :send_message
        get :withdraws
        get :crowdfunding_withdraws
      end
      member do
        post :lock
        post :unlock
        patch :update_verified
        post :update_withdraw
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
    resources :showcases do
      member do
        post :update_admin_status
        delete :delete_comment
      end
      collection do
        get :crowdfunding
      end
    end
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
      post :update_business
      post :update_address
      patch :update_social
      patch :update_wish_settings
      get :username_available
      get :verify_mobile
      patch :get_otp
      patch :resend_otp
      patch :verify_otp
      post :send_to_bank
      post :send_to_bank_form
      get :unlock_coin_wish
      get :verify_profile
      get :unlock_crowd_funding
      get :convert_to_profile_money_form
      post :convert_to_profile_money
    end
    member do
      post :delete_withdraw_request
    end
  end

  get :invitations, to: "invitations#index", as: :invitations
  post "invitations/send_email", to: "invitations#send_email", as: :send_email_invitations

  get "settings/account", to: "profiles#index", as: :settings
  get "settings", to: "profiles#settings", as: :root_settings
  get "settings/business", to: "profiles#business_profile"
  get "settings/password", to: "profiles#password"
  get "settings/social", to: "profiles#social"
  get "settings/addressbook", to: "profiles#addressbook"
  get "settings/wish", to: "profiles#wish_settings"
  get "dashboard", to: "profiles#dashboard"
  get :about, to: "home#about"
  get :terms, to: "home#terms"
  get :privacy, to: "home#privacy"
  get :contact, to: "home#contact"
  get "goodness-and-open-source", to: "home#goodness_and_open_source"
  get "jobs", to: "home#jobs"
  get "hackers", to: "home#hackers"
  get :sitemap, to: "home#sitemap"
  get "check_email", to: "home#check_email", as: :home_check_email
  get "home/get_state_and_city", to: "home#get_state_and_city"
  get "confirmation", to: "home#user_signup_confirmation"
  get "info", to: "profiles#info"
  get "interests", to: "home#interests"
  get "rent", to: "home#index"
  get "people", to: "home#following_all", as: :following_all
  get "authenticate", to: "home#authenticate"
  post :bulk_bookings, to: "home#bulk_bookings"
  get "offers", to: "home#offers"
  get "feed", to: "home#feed"
  get "results", to: "showcases#results"
  get "giftbox", to: "profiles#wallet", as: :wallet
  get "profiles", to: "home#user_results", as: :user_results
  get "user_autocomplete", to: "home#user_autocomplete"
  get "unchecked_notifications", to: "home#unchecked_notifications", as: :unchecked_notifications
  get "notifications", to: "home#notifications", as: :notifications
  get "update_all_notifications", to: "home#update_all_notifications", as: :update_all_notifications
  get "get_similar_friends", to: "home#get_similar_friends"
  post "toggle_follow/:id", to: "home#toggle_follow", as: :user_toggle_follow
  post "follow_all_interest", to: "home#follow_all_interest", as: :follow_all_interest
  post "unfollow_all_interest", to: "home#unfollow_all_interest", as: :unfollow_all_interest
  post "toggle_follow_interest/:id", to: "home#toggle_follow_interest", as: :user_toggle_follow_interest
  get ":id/wishes/fulfilled", to: "home#myshowpieces", as: :myshowpieces
  get ":id/wishes/future", to: "home#mywishes", as: :mywishes
  get ":id/wishes/momentary", to: "home#mymomentary", as: :mymomentary
  get ":id/showcases/:name", to: "home#view_collection", as: :view_collection
  get ":id/following", to: "home#following", as: :following
  get ":id/followers", to: "home#followers", as: :followers
  get ":id/wiki", to: "home#wiki", as: :wiki
  get ":id/giveaways", to: "giveaways#index", as: :view_giveaways
  post "create_wiki", to: "home#create_wiki", as: :create_wiki
  patch "edit_wiki/:id", to: "home#edit_wiki", as: :edit_wiki
  delete "delete_wiki/:id", to: "home#delete_wiki", as: :delete_wiki
  get "user_card/:id", to: "home#user_card", as: :get_user_card
  get "check_wow/:id", to: "home#update_wow_checked", as: :update_wow_checked
  get "check_coin/:id", to: "home#update_coin_checked", as: :update_coin_checked
  get "check_comment/:id", to: "home#update_comment_checked", as: :update_comment_checked
  get "check_follower/:id", to: "home#update_follower_checked", as: :update_follower_checked
  get "check_showcase/:id", to: "home#update_showcase_checked", as: :update_showcase_checked
  get "check_achieved/:id", to: "home#update_achieved_checked", as: :update_achieved_checked
  get "check_commenter/:id", to: "home#update_commenter_checked", as: :update_commenter_checked
  get "check_fundreceived/:id", to: "home#update_fundreceived_checked", as: :update_fundreceived_checked
  get "tags/:tag", to: "showcases#tagged_showcases", as: :tag
  get "fansday", to: "home#fansday"
  get "conversations", to: "chat_rooms#conversations", as: :chat_messages
  get "home/get-wishes", to: "home#get_showcases", as: :get_showcases
  get "home/get-all-wishes", to: "home#get_all_showcases", as: :get_all_showcases
  get "cocopay", to: "home#cocopay"
  get "refund", to: "home#refund"
  get "mobile", to: "home#mobile"
  post "home/save_firebase_token", to: "home#save_firebase_token", as: :save_firebase_token

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
  match "showcases/:id", to: "showcases#show", via: "get"
  get "wish/private/:access_token", to: "showcases#private_showcase"
  resources :showcases, path: "wish", only: [:edit, :create, :update, :destroy, :show] do
    member do
      post :wow
      post :comment
      post :edit_comment
      delete :delete_comment
      post :edit_collection
      delete :delete_collection
      post :rewish
      post :have_done_this
      post :coin
      post :undo_achieve_wish
      post :fullfillment_form
      post :update_fullfilment_details
      post :update_rating
      post :backstory_form
      post :update_backstory
      post :end_campaign
    end
    collection do
      get :gettags
      get :autocomplete
      post :create_collection
      post :add
      post :multiple_rewish
      post :add_coin_wish
    end
  end

  resources :chat_rooms, path: "chatrooms" do
    member do
      get :get_sub_categories
      get :get_chat_messages
      post :update_last_seen
      get :new_chat_for_crowd_fund
    end
    collection do
      get :autocomplete
    end
  end

  resources :giveaways, except: [:index] do
    member do
      post :request_giveaway
    end
  end

  post "product/:id/checkout", to: "transactions#new", as: :product_checkout
  post "product/:id/non_coco", to: "transactions#non_coco", as: :non_coco_transaction
  get "/categories/:id", to: "products#category", as: :category
  get "/listings/:id", to: "products#show", as: :user_product

  get ":id", to: "home#myprofile", as: :myprofile
  root 'home#feed'

end
