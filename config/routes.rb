
Rails.application.routes.draw do
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
  root "web/sessions#create"
  get "/seller", to: "sellers/applications#new", as: :seller

  get "/login", to: "web/sessions#new"
  post "/login", to: "web/sessions#create"
  delete "/logout", to: "web/sessions#destroy"

  get "/signup", to: "web/registrations#new"
  post "/signup", to: "web/registrations#create"

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
  resources :orders, only: [:index, :show, :create, :update]

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

  # Admin
  namespace :admin do
    root "dashboard#index"

    resources :seller_applications, only: [:index, :show, :update]
  end
end
