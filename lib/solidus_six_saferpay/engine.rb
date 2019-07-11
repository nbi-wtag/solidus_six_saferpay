module SolidusSixSaferpay
  class Engine < ::Rails::Engine
    require 'spree/core'
    require 'hashie'
    require 'hashie/mash'

    isolate_namespace SolidusSixSaferpay

    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    initializer "spree.six_payment.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::SaferpayPaymentPage
      app.config.spree.payment_methods << Spree::PaymentMethod::SaferpayTransaction
    end

    initializer "solidus_six_payments.assets.precompile" do |app|
      app.config.assets.precompile += %w( solidus_six_saferpay/saferpay_payment.js )
      app.config.assets.precompile += %w( solidus_six_saferpay/credit_cards/**/*.png )
    end
  end
end
