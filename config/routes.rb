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
    get 'companies/:id', to: 'companies#show'
    resources :cars, only: [:index, :show, :create, :update, :destroy] do
    end
    resources :company_logos, only: [:destroy]
  end
end