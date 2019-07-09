module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    class InitializePaymentPage < InitializeCheckout

      private

      def gateway_class
        ActiveMerchant::Billing::Gateways::SixSaferpayPaymentPageGateway
      end

      def checkout_interface_class
        SixSaferpay::SixPaymentPage::Initialize
      end
    end
  end
end
