module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    class InitializeTransaction < InitializeCheckout

      private

      def gateway_class
        ActiveMerchant::Billing::Gateways::SixSaferpayTransactionGateway
      end

      def payment_source_attributes(initialize_response_params)
        super.merge(
          redirect_url: initialize_response_params[:redirect][:redirect_url],
        )
      end
    end
  end
end
