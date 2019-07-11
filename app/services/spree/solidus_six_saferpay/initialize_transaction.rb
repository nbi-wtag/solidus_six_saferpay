module Spree
  module SolidusSixSaferpay

    # TODO: SPEC
    class InitializeTransaction < InitializeCheckout

      private

      def gateway_class
        ::SolidusSixSaferpay::TransactionGateway
      end

      def payment_source_attributes(initialize_response)
        super.merge(
          redirect_url: initialize_response.redirect.redirect_url
        )
      end
    end
  end
end
