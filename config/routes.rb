Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    # GET /
    root "static_pages#home"


    # User routes
    # GET /users/:id, GET /users/:id/edit, PATCH /users/:id
    resources :users, only: %i[show edit update]

    # Product routes
    # GET /products, GET /products/:id
    resources :products, only: %i[index show]


    # Cart routes
    # GET /cart
    get "/cart", to: "carts#show"
    # POST /cart/add
    post "/cart/add", to: "carts#add_item"
    # PATCH /cart/items/:id
    patch "/cart/items/:id", to: "carts#update_item", as: :cart_update_item
    # DELETE /cart/items/:id
    delete "/cart/items/:id", to: "carts#destroy_item", as: :cart_destroy_item
    # DELETE /cart/clear
    delete "/cart/clear", to: "carts#clear", as: :cart_clear

    # Checkout routes
    # GET /checkout
    get "/checkout", to: "checkout#new"
    # POST /checkout
    post "/checkout", to: "checkout#create"
    # GET /checkout/success/:order_number
    get "/checkout/success/:order_number", to: "checkout#success", as: :checkout_success

    # Order routes
    # GET /orders, GET /orders/:id, PATCH /orders/:id/cancel
    resources :orders, only: %i[index show] do
      member do
        patch :cancel
      end
    end

    # Static pages
    # GET /help, GET /about, GET /contact
    get "/help", to: "static_pages#help"
    get "/about", to: "static_pages#about"
    get "/contact", to: "static_pages#contact"

    # User authentication
    # GET /signup, POST /signup
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    # GET /login, POST /login, DELETE /logout
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    # Admin routes
    namespace :admin do
      root "dashboard#index"
      resources :categories do
        member do
          patch :update_position
          patch :toggle_status
        end
        collection do
          patch :sort
        end
      end
      resources :products do
        member do
          patch :toggle_status
          patch :toggle_featured
          delete "remove_image/:image_id", to: "products#remove_image", as: :remove_image
        end
        collection do
          patch :sort
        end
      end

      resources :users, only: [:index, :show] do
        member do
          patch :toggle_status
        end
        collection do
          patch :bulk_update
        end
      end
    end
  end
end
