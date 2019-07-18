module Spree
  module SolidusSixSaferpay
    module UsePaymentPageGateway
      include UseGateway

      private

      def gateway
        ::SolidusSixSaferpay::PaymentPageGateway.new(
          success_url: url_helpers.solidus_six_saferpay_payment_page_init_url,
          fail_url: url_helpers.solidus_six_saferpay_payment_page_fail_url,
        )
      end
    end
  end
end
