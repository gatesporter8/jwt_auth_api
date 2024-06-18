Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs', as: 'rswag_ui'
  mount Rswag::Api::Engine => '/api-docs', as: 'rswag_api'
  namespace :api do
    post '/register', to: 'authentication#register'
    post '/login', to: 'authentication#login'
  end
end
