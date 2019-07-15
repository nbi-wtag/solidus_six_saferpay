module Spree
  class PaymentMethod::SaferpayTransaction < PaymentMethod::SixSaferpayPaymentMethod

    def gateway_class
      ::SolidusSixSaferpay::TransactionGateway
    end

    def partial_name
      :saferpay_transaction
    end
  end
end
