Spree::Core::Engine.routes.draw do

  namespace :solidus_six_saferpay do
    scope :payment_page do
      get 'init', controller: 'saferpay_payment_page', defaults: { format: :json }, as: :payment_page_init
      get 'success', controller: 'saferpay_payment_page', as: :payment_page_success
      get 'fail', controller: 'saferpay_payment_page', as: :payment_page_fail
      get 'cancel', controller: 'saferpay_payment_page', as: :payment_page_cancel
    end

    scope :transaction do
      get 'init', controller: 'saferpay_transaction', defaults: { format: :json }, as: :transaction_init
      get 'success', controller: 'saferpay_transaction', as: :transaction_success
      get 'fail', controller: 'saferpay_transaction', as: :transaction_fail
      get 'cancel', controller: 'saferpay_transaction', as: :transaction_cancel
    end
  end

end
