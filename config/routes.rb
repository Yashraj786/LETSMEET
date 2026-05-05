Rails.application.routes.draw do
  # ---------------------------------------------------------------------------
  # Devise — override registrations controller to enforce referral code gate
  # ---------------------------------------------------------------------------
  devise_for :users,
             controllers: { registrations: "devise/registrations" }

  # ---------------------------------------------------------------------------
  # Public landing page
  # ---------------------------------------------------------------------------
  root "pages#home"
  get "home", to: "pages#home", as: :pages_home

  # ---------------------------------------------------------------------------
  # Authenticated member area
  # ---------------------------------------------------------------------------
  get  "dashboard", to: "dashboard#index", as: :dashboard

  resources :profiles,   only: %i[show edit update]
  resources :hangouts do
    member do
      patch :cancel
      post  :rsvp
    end
  end

  resources :invitations, only: %i[index show new create] do
    member do
      patch :revoke
    end
  end

  # ---------------------------------------------------------------------------
  # Admin namespace — restricted to role_admin users
  # ---------------------------------------------------------------------------
  namespace :admin do
    root "dashboard#index"
    resources :users, only: %i[index show edit update destroy] do
      member do
        patch :grant_admin
        patch :revoke_admin
        post  :mint_referral_code
      end
    end
  end

  # Health check endpoint for load balancers / uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check
end
