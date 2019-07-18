module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    class InitializeTransaction < InitializePayment
      include UseTransactionGateway

      private

      def saferpay_payment_attributes(initialize_response)
        super.merge(
          redirect_url: initialize_response.redirect.redirect_url
        )
      end
    end
  end
end
