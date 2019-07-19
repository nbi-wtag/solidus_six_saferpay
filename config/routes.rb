# Spree::Core::Engine.routes.draw do

#   namespace :solidus_six_saferpay do
#     scope :payment_page do
#       get 'init', controller: 'payment_page_checkout', defaults: { format: :json }, as: :payment_page_init
#       get 'success', controller: 'payment_page_checkout', as: :payment_page_success
#       get 'fail', controller: 'payment_page_checkout', as: :payment_page_fail
#       get 'cancel', controller: 'payment_page_checkout', as: :payment_page_cancel
#     end

#     scope :transaction do
#       get 'init', controller: 'transaction_checkout', defaults: { format: :json }, as: :transaction_init
#       get 'success', controller: 'transaction_checkout', as: :transaction_success
#       get 'fail', controller: 'transaction_checkout', as: :transaction_fail
#       get 'cancel', controller: 'transaction_checkout', as: :transaction_cancel
#     end
#   end

# end
