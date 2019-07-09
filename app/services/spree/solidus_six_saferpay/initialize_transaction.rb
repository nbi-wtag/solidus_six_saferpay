module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    class InitializeTransaction < InitializeCheckout

      private

      def gateway_class
        ActiveMerchant::Billing::Gateways::SixSaferpayTransactionGateway
      end

      def checkout_interface_class
        SixSaferpay::SixTransaction::Initialize
      end
    end
  end
end
