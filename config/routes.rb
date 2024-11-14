# config/routes.rb
Rails.application.routes.draw do
  # Ruta para el chatbot en /chatbot
  get 'chatbot', to: 'questions#index'
  post 'chatbot', to: 'questions#create'

  # Monta Solidus en la raíz
  mount Spree::Core::Engine, at: '/'
end

