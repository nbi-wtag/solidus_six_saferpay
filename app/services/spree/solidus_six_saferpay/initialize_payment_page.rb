module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    class InitializePaymentPage < InitializeCheckout

      private

      def gateway_class
        ActiveMerchant::Billing::Gateways::SixSaferpayPaymentPageGateway
      end

      def payment_source_attributes(initialize_response_params)
        super.merge(
          redirect_url: initialize_response_params[:redirect_url],
        )
      end
    end
  end
end
