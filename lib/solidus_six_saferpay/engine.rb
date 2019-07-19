module SolidusSixSaferpay
  class Engine < ::Rails::Engine
    # require 'spree/core'

    isolate_namespace SolidusSixSaferpay

    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    # initializer "spree.six_payment.payment_methods", :after => "spree.register.payment_methods" do |app|
    #   app.config.spree.payment_methods << Spree::PaymentMethod::SaferpayPaymentPage
    #   app.config.spree.payment_methods << Spree::PaymentMethod::SaferpayTransaction
    # end

    initializer "solidus_six_payments.assets.precompile" do |app|
      app.config.assets.precompile += %w( solidus_six_saferpay/application.css )
      app.config.assets.precompile += %w( solidus_six_saferpay/saferpay_payment.js )
      app.config.assets.precompile += %w( solidus_six_saferpay/credit_cards/**/*.png )
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
  end
end
