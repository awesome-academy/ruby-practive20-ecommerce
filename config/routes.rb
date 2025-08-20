Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    
    resources :users, only: %i[show]
    resources :products, only: %i[index show]
    
    get "/help", to: "static_pages#help"
    get "/about", to: "static_pages#about"
    get "/contact", to: "static_pages#contact"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
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
    end
  end
end
