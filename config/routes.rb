  Rails.application.routes.draw do
    devise_for :users, path: '', path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'signup'
    },
               controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
               }

    resources :cars, only: [:index, :show, :create, :update, :destroy]

  end

