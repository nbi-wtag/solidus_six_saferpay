module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    class InitializePaymentPage < InitializePayment
      include UsePaymentPageGateway

      private

      def payment_source_attributes(initialize_response)
        super.merge(
          redirect_url: initialize_response.redirect_url
        )
      end
    end
  end
end
