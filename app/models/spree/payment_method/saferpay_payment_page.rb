module Spree
  class PaymentMethod::SaferpayPaymentPage < PaymentMethod::SixSaferpayPaymentMethod

    def gateway_class
      ::SolidusSixSaferpay::PaymentPageGateway
    end

    def partial_name
      :saferpay_payment_page
    end
  end
end
