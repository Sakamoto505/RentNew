  Rails.application.routes.draw do
  scope 'api' do
    devise_for :users, path: '', path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'signup'
    },
               controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
               }
    get '/my_cars', to: 'cars#my_cars'

    get 'company_profile', to: 'companies#show_profile'
    patch 'company_profile', to: 'companies#update_profile'
    get 'companies/:company_name', to: 'companies#show'
    get 'company_names', to: 'companies#company_names'
    resources :cars, only: [:index, :show, :create, :update, :destroy] do
      collection do
        post :bulk_show
        get :total_count
        get :cars_for_sitemap
      end
    end
    resources :company_logos, only: [:destroy]
    resources :car_images, only: [:destroy]
    resources :favorites, only: [:index, :create] do
      collection do
        delete :destroy
      end
    end
    
    resources :subscriptions do
      collection do
        get :current_status
      end
      member do
        post :extend
      end
    end
    
    # Черный список
    post 'blacklist', to: 'blacklist#create'
    get 'blacklist/mine', to: 'blacklist#mine'
    post 'blacklist/search', to: 'blacklist#search'
    delete 'blacklist/:id', to: 'blacklist#destroy'
    
    # Секретный просмотр компаний
    get 'secret/companies-list-x9k2l3m8', to: 'companies_list#index'
    
    # Админские методы
    namespace :admin do
      patch 'users/:user_id/verification', to: 'admin#update_verification'
      
      # Админ панель API
      get 'companies', to: 'admin_panel#companies'
      get 'companies/:id', to: 'admin_panel#show_company'
      patch 'companies/:id', to: 'admin_panel#update_company'
      get 'credentials', to: 'admin_panel#credentials'
    end
  end
end