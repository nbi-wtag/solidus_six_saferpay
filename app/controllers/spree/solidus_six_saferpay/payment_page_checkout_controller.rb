module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    # explicit parent must be stated, otherwise Spree::CheckoutController has precendence
    class PaymentPageCheckoutController < SolidusSixSaferpay::CheckoutController

      private

      def initialize_checkout(order, payment_method)
        InitializePaymentPage.call(order, payment_method)
      end

      def authorize_payment(payment_source)
        AssertPaymentPage.call(payment_source)
      end
    end
  end
end
