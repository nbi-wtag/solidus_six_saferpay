module Spree
  module SolidusSixSaferpay
  # TODO: SPEC
    # explicit parent must be stated, otherwise Spree::CheckoutController has precendence
    class TransactionCheckoutController < SolidusSixSaferpay::CheckoutController

      private

      def initialize_checkout(order, payment_method)
        InitializeTransaction.call(order, payment_method)
      end
    end
  end
end
