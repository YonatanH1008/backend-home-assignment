# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "#{SWAGGER_SERVICE_PATH_PREFIX_DEFAULT}/docs"
  mount Rswag::Api::Engine => "#{SWAGGER_SERVICE_PATH_PREFIX_DEFAULT}/docs"

  namespace :api, defaults: { format: :json } do
    resources :status, only: [:index]
    get '/elastalert/:status', to: 'elastalert#show', as: 'elastalert'
    namespace :v1 do
      resources :examples
      resources :vehicles
      resources :fleets
    end
  end
end
