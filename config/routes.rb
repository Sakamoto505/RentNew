Rails.application.routes.draw do
    root 'application#index'

    # API маршруты под префиксом /api
    scope '/api' do
        get "/current_user", to: "current_user#index"
        patch "/current_user", to: "current_user#update"
        put "/current_user", to: "current_user#update"

        get "/doctors", to: "current_user#all_doctors"
        get "/doctors/:id", to: "current_user#show"

        get "/my_availabilities", to: "availabilities#my_availabilities"
        get "/my_appointments", to: "appointments#my_appointments"
        patch "/appointments/:id", to: "appointments#update"
        delete "/appointments/:id/cancel", to: "appointments#cancel"

        resources :appointments, only: [:index, :create]
        resources :availabilities, only: [:index, :create]
        delete "/availabilities", to: "availabilities#destroy_slots"

        # Чаты
        resources :chats, only: [:index, :create, :show] do
            resources :messages, only: [:index, :create]
        end

        # Файлы
        get "/uploads/*path", to: "uploads#show"

        # --- Твои кастомные ресурсы ---
        get "/company_profile", to: "companies#show_profile"
        patch "/company_profile", to: "companies#update_profile"
        get "/companies/:id", to: "companies#show"

        resources :cars, only: [:index, :show, :create, :update, :destroy] do
            collection do
                get "my_cars"
            end
        end

        resources :company_logos, only: [:destroy]
    end

    # Аутентификация — без префикса /api для совместимости
    devise_for :users, path: "", path_names: {
      sign_in: "login",
      sign_out: "logout",
      registration: "signup"
    },
               controllers: {
                 sessions: "users/sessions",
                 registrations: "users/registrations"
               }

    # ActionCable
    mount ActionCable.server => '/cable'
end
