# config/routes.rb
Rails.application.routes.draw do
  resources :questions, only: [:index, :create] do

  end
  get '/chatbot', to: 'questions#index', as: 'chatbot' # Ruta personalizada para el chatbot

  # Montar las rutas de Solidus en la raíz
  mount Spree::Core::Engine, at: '/'
end