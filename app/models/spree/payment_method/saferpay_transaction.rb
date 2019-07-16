module Spree
  class PaymentMethod::SaferpayTransaction < PaymentMethod::SixSaferpayPaymentMethod

    def gateway_class
      ::SolidusSixSaferpay::TransactionGateway
    end
  end
end
