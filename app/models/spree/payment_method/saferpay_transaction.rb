module Spree
  class PaymentMethod::SaferpayTransaction < PaymentMethod::SixSaferpayPaymentMethod

    def gateway_class
      ::SolidusSixSaferpay::TransactionGateway
    end

    def init_path
      url_helpers.solidus_six_saferpay_transaction_init_path
    end
  end
end
