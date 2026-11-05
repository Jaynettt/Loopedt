
Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  get 'looks/new'
  get 'looks/create'
  get 'looks/show'
  # Seller routes
  namespace :sellers do
    get "dashboard/index"
    get "applications/new"
    post "applications/create"
  end
  get "/sellers/:id",
    to: "sellers/profiles#show",
    as: :seller_profile
  # Cart routes
  resources :cart_items, only: [:index, :create, :update, :destroy]

  # Authentication
  root "listings#index"
  get "/seller", to: "sellers/applications#new", as: :seller

  get "/login", to: "web/sessions#new"
  post "/login", to: "web/sessions#create"
  delete "/logout", to: "web/sessions#destroy"

  get "/signup", to: "web/registrations#new"
  post "/signup", to: "web/registrations#create"
  # My Profile
  get "/my-profile", to: "web/profiles#show", as: :my_profile
  get "/my-profile/edit", to: "web/profiles#edit", as: :edit_my_profile
  patch "/my-profile", to: "web/profiles#update"

  # Messaging
  post "/inbox/:id/messages",
       to: "web/conversations#create_message",
       as: :send_inbox_message

  post "/listings/:listing_id/message_seller",
       to: "web/conversations#create_for_listing",
       as: :message_listing_seller

  get "/inbox",
      to: "web/conversations#index",
      as: :inbox

  get "/inbox/:id",
      to: "web/conversations#show",
      as: :inbox_conversation

      # Style Finder results
  get "/style-results",
    to: "listings#style_results",
    as: :style_results

  # Users
  resources :users do
    resources :favorites, only: [:index]
  end
  # Recreate My Look
  resources :looks, only: [:new, :create, :show]

  # Categories
  resources :categories

  # Listings and favorites
  resources :listings do
    resources :favorites, only: [:create, :destroy]
  end

  # Orders
  # Website orders
  get "/orders", to: "web/orders#index", as: :orders
  get "/orders/:id", to: "web/orders#show", as: :order
  patch "/orders/:id/ready_for_dispatch",
      to: "web/orders#ready_for_dispatch",
      as: :ready_for_dispatch_order

  # Conversations
  resources :conversations, only: [:index, :show, :create] do
    post :create_message, on: :member
  end

  # Seller onboarding
  get "/seller-onboarding",
      to: "sellers/applications#new",
      as: :seller_onboarding

  post "/seller-onboarding",
       to: "sellers/applications#create"

       get "/seller-onboarding/kyc",
       to: "sellers/applications#kyc",
       as: :seller_onboarding_kyc

   patch "/seller-onboarding/kyc",
         to: "sellers/applications#update_kyc",
         as: :update_seller_onboarding_kyc

   patch "/seller-onboarding/submit",
         to: "sellers/applications#submit",
         as: :submit_seller_onboarding

  # Seller application tracking
  get "/seller/application",
      to: "sellers/applications#show",
      as: :seller_application

  # Seller dashboard
  get "/seller/dashboard",
      to: "sellers/dashboard#index",
      as: :seller_dashboard


  get "/checkout/callback",
      to: "web/checkouts#callback",
      as: :paystack_callback

  post "/checkout/:id/pay",
      to: "web/checkouts#pay",
      as: :pay_checkout


  get "/checkout/:id",
    to: "web/checkouts#show",
    as: :checkout

  post "/checkout",
      to: "web/checkouts#create",
      as: :create_checkout

      post "/inbox/:id/negotiation/request",
      to: "web/negotiations#request_negotiation",
      as: :request_negotiation

  post "/inbox/:id/negotiation/respond",
      to: "web/negotiations#respond_to_request",
      as: :respond_to_negotiation_request

  post "/inbox/:id/negotiation/offers",
      to: "web/negotiations#create_offer",
      as: :create_negotiation_offer

  post "/inbox/:id/negotiation/offers/:offer_id/respond",
      to: "web/negotiations#respond_to_offer",
      as: :respond_to_negotiation_offer

    # Admin
  namespace :admin do
    root "dashboard#index"

    resources :seller_applications, only: [:index, :show, :update] do
      member do
        get :identity_document
        get :proof_of_address
        get :identity_document_preview
      end
    end
  end
end
