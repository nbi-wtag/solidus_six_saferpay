Spree::Core::Engine.routes.draw do

  namespace :solidus_six_saferpay do
    namespace :payment_page do
      get :initialize_payment, controller: :checkout, defaults: { format: :json }
      get :success, controller: :checkout
      get :fail, controller: :checkout
    end

    namespace :transaction do
      get :initialize_payment, controller: :checkout, defaults: { format: :json }
      get :success, controller: :checkout
      get :fail, controller: :checkout
    end
  end

end
