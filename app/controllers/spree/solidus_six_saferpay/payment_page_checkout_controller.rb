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

      def process_authorization(payment_source)
        ProcessPaymentPagePayment.call(payment_source)
      end

      def inquire_payment(payment_source)
        InquirePaymentPage.call(payment_source)
      end
    end
  end
end
