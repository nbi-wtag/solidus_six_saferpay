module Spree
  module SolidusSixSaferpay
    # TODO: SPEC
    # explicit parent must be stated, otherwise Spree::CheckoutController has precendence
    class PaymentPageCheckoutController < SolidusSixSaferpay::CheckoutController

      private

      def initialize_checkout(order, payment_method)
        InitializePaymentPage.call(order, payment_method)
      end

      def authorize_payment(saferpay_payment)
        AssertPaymentPage.call(saferpay_payment)
      end

      def process_authorization(saferpay_payment)
        ProcessPaymentPagePayment.call(saferpay_payment)
      end

      def inquire_payment(saferpay_payment)
        InquirePaymentPage.call(saferpay_payment)
      end
    end
  end
end
