module Spree
  module SolidusSixSaferpay
    module UseTransactionGateway
      include RouteAccess

      def gateway
        ::SolidusSixSaferpay::TransactionGateway.new(
          success_url: url_helpers.solidus_six_saferpay_transaction_init_url,
          fail_url: url_helpers.solidus_six_saferpay_transaction_fail_url,
        )
      end
    end
  end
end
