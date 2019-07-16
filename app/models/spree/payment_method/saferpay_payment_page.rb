module Spree
  class PaymentMethod::SaferpayPaymentPage < PaymentMethod::SixSaferpayPaymentMethod

    def gateway_class
      ::SolidusSixSaferpay::PaymentPageGateway
    end
  end
end
