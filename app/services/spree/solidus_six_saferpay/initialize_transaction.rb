module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    class InitializeTransaction < InitializePayment
      include UseTransactionGateway

      private

      def payment_source_attributes(initialize_response)
        super.merge(
          redirect_url: initialize_response.redirect.redirect_url
        )
      end
    end
  end
end
