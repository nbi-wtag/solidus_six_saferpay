Spree::Core::Engine.routes.draw do

  namespace :solidus_six_saferpay do
    namespace :payment_page do
      get :init, controller: :checkout, defaults: { format: :json }
      get :success, controller: :checkout
      get :fail, controller: :checkout
    end

    namespace :transaction do
      get 'init/:payment_method_id', controller: :checkout, action: :init, as: :init, defaults: { format: :json }
      get :success, controller: :checkout
      get :fail, controller: :checkout
    end

    # OLD ROUTES
    # get 'payment_page/init/:payment_method_id', to: 'payment_page_checkout#init', as: :payment_page_init
    # get 'payment_page_init/:payment_method_id', to: 'payment_page_checkout_controller#init'
    # scope :payment_page do
    #   get 'init/:payment_method_id', controller: 'payment_page_checkout', action: :init, defaults: { format: :json }, as: :payment_page_init
    #   get 'payment_page_init', to: 'payment_page_checkout#init'
    #   get 'success', controller: 'payment_page_checkout', as: :payment_page_success
    #   get 'fail', controller: 'payment_page_checkout', as: :payment_page_fail
    #   get 'cancel', controller: 'payment_page_checkout', as: :payment_page_cancel
    # end

    # scope :transaction do
    #   get 'init', controller: 'transaction_checkout', defaults: { format: :json }, as: :transaction_init
    #   get 'success', controller: 'transaction_checkout', as: :transaction_success
    #   get 'fail', controller: 'transaction_checkout', as: :transaction_fail
    #   get 'cancel', controller: 'transaction_checkout', as: :transaction_cancel
    # end
  end

end
